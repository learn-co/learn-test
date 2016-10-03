require 'spec_helper'

describe LearnTest::LessonProfile do
  let!(:lesson_profile) do
    LearnTest::LessonProfile.new('test-repo', 'test-oauth-token')
  end

  before do
    allow(lesson_profile).to receive(:ignore_lesson_profile!).at_least(:once)
    allow(LearnTest::RepoParser).to receive(:get_repo).and_return('test-lesson')

    lesson_profile_payload = {
      'payload' => {
        'lid' => 0,
        'uuid' => '1q2w3e4r5t6y7u8i',
        'aaq_trigger' => true
      }
    }

    allow(lesson_profile).to receive(:request_data).and_return(lesson_profile_payload)

    @current_dir = Dir.pwd
    @tmp_lesson_dir = Dir.mktmpdir

    Dir.chdir(@tmp_lesson_dir)
  end

  it '#aaq_triggered! marks aaq as having been run' do
    lesson_profile.aaq_triggered!
    expect(lesson_profile.aaq_trigger_processed?).to eq true
  end

  after do
    Dir.chdir(@current_dir)
    FileUtils.remove_entry(@tmp_lesson_dir)
  end
end
