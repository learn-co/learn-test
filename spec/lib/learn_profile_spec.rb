require 'spec_helper'

describe LearnTest::LearnProfile do
  let! (:profile) do
    LearnTest::LearnProfile.new('test-oauth-token')
  end


  describe '#sync!' do
    let (:new_profile) do
      {
        "features" => {
          "aaq_intervention" => true
        },
        "generated_at" => 1475512844
      }
    end

    before do
      allow_any_instance_of(LearnTest::LearnProfile).to receive(:request_profile).and_return(new_profile)
    end

    context 'when the learn profile does not yet exist' do
      it 'requests and writes the learn profile' do
        profile.sync!
        learn_profile = profile.send(:read_profile)

        expect(learn_profile["generated_at"]).to eq(new_profile["generated_at"])
      end
    end

    context 'when the learn profile is older than one day' do
      it 'requests a new profile' do
        allow_any_instance_of(LearnTest::LearnProfile).to receive(:needs_update?).and_return(true)
        profile.sync!
        learn_profile = profile.send(:read_profile)
        expect(learn_profile["generated_at"]).to eq(new_profile["generated_at"])
      end
    end

    context 'when the learn profile was updated within the last day' do
      it 'does not request a new profile' do
        allow_any_instance_of(LearnTest::LearnProfile).to receive(:needs_update?).and_return(false)
        profile.sync!
        learn_profile = profile.send(:read_profile)
        expect(learn_profile["generated_at"]).to eq(0)
      end
    end
  end

  describe '#should_trigger?' do
    let (:feature_on_payload) do
      {
        "features" => {
          "aaq_intervention" => true
        },
        "generated_at" => 1475512844
      }
    end

    let (:feature_off_payload) do
      {
        "features" => {
          "aaq_intervention" => false
        },
        "generated_at" => 1475512844
      }
    end

    context 'when the feature is turned on for the user' do
      it 'returns true' do
        allow_any_instance_of(LearnTest::LearnProfile).to receive(:read_profile).and_return(feature_on_payload)

        expect(profile.should_trigger?).to eq(true)
      end
    end

    context 'when the feature is not turned on for the user' do
      it 'returns false' do
        allow_any_instance_of(LearnTest::LearnProfile).to receive(:read_profile).and_return(feature_off_payload)

        expect(profile.should_trigger?).to eq(false)
      end
    end
  end

  after do
    profile_path = "#{ENV['HOME']}/.learn_profile"
    FileUtils.remove_file(profile_path) if File.exist?(profile_path)
  end
end
