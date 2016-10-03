require 'spec_helper'

describe LearnTest::LearnProfile do
  let! (:profile) do
    LearnTest::LearnProfile.new('test-oauth-token')
  end

  before do
    new_profile = { 
      "features" => {
        "intervention" => true
      },
      "generated_at" => 1475512844
    }
    allow_any_instance_of(LearnTest::LearnProfile).to receive(:request_profile).and_return(new_profile)
  end

  describe '#sync!' do
    context 'when the learn profile does not yet exist' do
      it 'requests and writes the learn profile' do
        profile.sync!
        learn_profile = profile.send(:read_profile)

        expect(learn_profile["generated_at"]).to eq(1475512844)
      end
    end

    context 'when the learn profile is older than one day' do
      it 'requests a new profile' do
        allow_any_instance_of(LearnTest::LearnProfile).to receive(:needs_update?).and_return(true)
        profile.sync!
        learn_profile = profile.send(:read_profile)
        expect(learn_profile["generated_at"]).to eq(1475512844)
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


  after do
    profile_path = "#{ENV['HOME']}/.learn_profile"
    FileUtils.remove_file(profile_path) if File.exist?(profile_path)
  end
end
