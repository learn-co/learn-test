require 'spec_helper'

describe LearnTest::InterventionPrompter do
  let (:learn_profile) do
    LearnTest::LearnProfile.new('test-oauth-token')
  end

  let (:intervention_prompter) do
    LearnTest::InterventionPrompter.new({}, 'test-repo', 'test-oauth-token', learn_profile)
  end

  describe '#ask_a_question_triggered?' do
    context 'when it has already been triggered' do
      it 'returns false' do
        allow_any_instance_of(LearnTest::InterventionPrompter).to receive(:already_triggered?).and_return(true)
        allow_any_instance_of(LearnTest::LessonProfile).to receive(:aaq_triggered?).and_return(true)

        expect(intervention_prompter.send(:ask_a_question_triggered?)).to eq(false)
      end
    end

    context 'when it is on a native windows environment' do
      it 'returns false' do
        allow_any_instance_of(LearnTest::InterventionPrompter).to receive(:windows_environment?).and_return(true)
        allow_any_instance_of(LearnTest::LessonProfile).to receive(:aaq_triggered?).and_return(true)

        expect(intervention_prompter.send(:ask_a_question_triggered?)).to eq(false)
      end
    end

    context 'when all the tests are passing' do
      it 'returns false' do
        allow_any_instance_of(LearnTest::InterventionPrompter).to receive(:all_tests_passing?).and_return(true)
        allow_any_instance_of(LearnTest::LessonProfile).to receive(:aaq_triggered?).and_return(true)

        expect(intervention_prompter.send(:ask_a_question_triggered?)).to eq(false)
      end
    end

    context 'when the lesson profile returns that aaq should trigger' do
      it 'returns true' do
        allow_any_instance_of(LearnTest::InterventionPrompter).to receive(:already_triggered?).and_return(false)
        allow_any_instance_of(LearnTest::InterventionPrompter).to receive(:windows_environment?).and_return(false)
        allow_any_instance_of(LearnTest::InterventionPrompter).to receive(:all_tests_passing?).and_return(false)
        allow(learn_profile).to receive(:should_trigger?).and_return(true)
        allow_any_instance_of(LearnTest::LessonProfile).to receive(:aaq_triggered?).and_return(true)

        expect(intervention_prompter.send(:ask_a_question_triggered?)).to eq(true)
      end
    end

  end
end
