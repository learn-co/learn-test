# frozen_string_literal: true

describe LearnTest::UsernameParser do
  subject { LearnTest::UsernameParser }

  let(:dbl) { instance_double(LearnTest::NetrcInteractor) }

  let!(:username) { 'learn-co' }
  let!(:user_id) { '12345' }
  let!(:token) { 'abc123' }

  context 'user details are stored in ~/.netrc' do
    context 'username/password' do
      it 'should return a username' do
        expect(LearnTest::LearnOauthTokenParser).to receive(:get_learn_oauth_token).and_return(token)

        expect(LearnTest::NetrcInteractor).to receive(:new).and_return(dbl)
        expect(dbl).to receive(:username).and_return(username)
        expect(dbl).to receive(:user_id).and_return(user_id)

        expect(dbl).to_not receive(:write)

        expect(subject.get_username).to eq(username)
      end
    end

    context 'oauth token' do
      it 'should return a username' do
        expect(LearnTest::LearnOauthTokenParser).to receive(:get_learn_oauth_token).and_return(token)

        expect(LearnTest::NetrcInteractor).to receive(:new).and_return(dbl)
        expect(dbl).to receive(:username).and_return(nil)
        expect(dbl).to receive(:user_id).and_return(nil)

        expect(dbl).to_not receive(:write)

        expect(subject.get_username).to eq(nil)
      end
    end
  end

  context 'user details are not stored in ~/.netrc' do
    it 'should ask for and store a username' do
      @original_stdout = $stdout
      $stdout = File.open(File::NULL, 'w')

      expect(LearnTest::LearnOauthTokenParser).to receive(:get_learn_oauth_token).and_return(nil)

      expect(LearnTest::NetrcInteractor).to receive(:new).and_return(dbl)
      expect(dbl).to receive(:username).and_return(nil)
      expect(dbl).to receive(:user_id).and_return(nil)

      expect($stdin).to receive(:gets).and_return(username)
      expect(LearnTest::GithubInteractor).to receive(:get_user_id_for).with(username).and_return(user_id)
      expect(dbl).to receive(:write).with(username, user_id)

      expect(subject.get_username).to eq(username)

      $stdout = @original_stdout
      @original_stdout = nil
    end
  end
end
