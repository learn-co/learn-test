module LearnTest
  class LessonProfile
    LESSON_PROFILE_FILENAME = '.lesson_profile'
    BASE_URL = 'https://qa.learn.flatironschool.com'
    PROMPT_ENDPOINT = "/api/cli/prompt.json"

    def initialize(repo_name, oauth_token)
      @repo_name = repo_name
      @oauth_token = oauth_token
    end

    def aaq_triggered!
      data["aaq_triggered_at"] = Time.now.to_i
      write!
    end

    def aaq_triggered?
      !aaq_trigger_processed? && data["aaq_trigger"] == true
    end

    def aaq_trigger_processed?
      !!(data["aaq_triggered_at"])
    end

    def lesson_id
      data["lid"]
    end

    def cli_event_uuid
      data["uuid"]
    end

    def sync!
      unless aaq_trigger_processed?
        payload = request_data["payload"]

        unless payload.nil?
          data['lid']         = payload['lid']
          data['uuid']        = payload['uuid']
          data['aaq_trigger'] = payload['aaq_trigger']
          write!
        end
      end
    end

    private

    attr_accessor :data
    attr_reader :repo_name, :oauth_token

    def request_data
      begin
        response = connection.get do |req|
          req.url(intervention_url)
          req.headers['Content-Type'] = 'application/json'
          req.headers['Authorization'] = "Bearer #{oauth_token}"
        end

        JSON.parse(response.body)
      rescue Faraday::ConnectionFailed
        nil
      end
    end

    def connection
      @connection ||= Faraday.new(url: base_url) do |faraday|
        faraday.adapter(Faraday.default_adapter)
      end
    end

    def intervention_url
      prompt_endpoint + "?repo_name=#{repo_name}"
    end

    def base_url
      BASE_URL
    end

    def prompt_endpoint
      PROMPT_ENDPOINT
    end

    def lesson_profile_path
      LESSON_PROFILE_PATH
    end

    def lesson_profile_path
      path = ENV['LESSON_PROFILE_PATH'] || Dir.pwd
      "#{path}/#{lesson_profile_filename}"
    end

    def lesson_profile_filename
      LESSON_PROFILE_FILENAME
    end

    def data
      @data ||= read
    end

    def write!
      ignore_lesson_profile!

      f = File.open(lesson_profile_path, 'w+')
      f.write(data.to_json)
      f.close
    end

    def read
      if File.exists?(lesson_profile_path)
        JSON.parse(File.read(lesson_profile_path))
      else
        new_profile
      end
    end

    def new_profile
      {
        "aaq_trigger" => false,
        "uuid" => ''
      }
    end

    def ignore_lesson_profile!
      File.open('.git/info/exclude', 'a+') do |f|
        contents = f.read
        unless contents.match(/\.lesson_profile/)
          f.puts('.lesson_profile')
        end
      end
    end
  end
end
