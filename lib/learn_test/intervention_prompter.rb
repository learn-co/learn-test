require 'socket'

module LearnTest
  class InterventionPrompter
    BASE_URL = 'https://qa.learn.flatironschool.com'

    attr_reader :results, :repo, :token, :profile

    def initialize(test_results, repo, token, profile)
      @results = test_results
      @repo = repo
      @token = token
      @profile = profile
      @lesson_profile = LessonProfile.new(repo, token)
    end

    def execute
      ask_a_question if ask_a_question_triggered?
    end

    private

    attr_reader :lesson_profile

    def ask_a_question
      response = ''
      until response == 'y' || response == 'n'
        puts <<-PROMPT
   /||
  //||
  // ||
  ||||||||||
    || //    Stuck on this Lab and want some help from an Expert?
    ||//
    ||/
   PROMPT
      print 'Enter (Y/n): '
      response = STDIN.gets.chomp.downcase
      end

      if response == 'y'
        puts "Good move. An Expert will be with you shortly on Ask a Question."
        browser_open(ask_a_question_url)
      else
        puts "No problem. You got this."
      end

      aaq_triggered!
    end

    def aaq_triggered!
      lesson_profile.aaq_triggered!
    end

    def base_url
      BASE_URL
    end

    def ask_a_question_url
      lesson_id = lesson_profile.lesson_id
      uuid = lesson_profile.cli_event_uuid

      base_url + "/lessons/#{lesson_id}?question_id=new&cli_event=#{uuid}"
    end

    def ask_a_question_triggered?
      return false unless profile.should_trigger?
      return false if already_triggered? || windows_environment? || all_tests_passing?

      lesson_profile.aaq_triggered?
    end

    def already_triggered?
      lesson_profile.aaq_trigger_processed?
    end

    def all_tests_passing?
      results[:failure_count] == 0
    end

    def browser_open(url)
      if ide_environment?
        ide_client.browser_open(url)
      elsif linux_environment?
        `xdg-open "#{url}"`
      else
        `open "#{url}"`
      end
    end

    def ide_client
      @ide_client ||= LearnTest::Ide::Client.new
    end

    def ide_environment?
      Socket.gethostname.end_with? '.students.learn.co'
    end

    def linux_environment?
      !!RUBY_PLATFORM.match(/linux/)
    end

    def windows_environment?
      !!RUBY_PLATFORM.match(/mswin|mingw|cygwin/)
    end
  end
end
