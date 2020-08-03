# frozen_string_literal: true

require 'faraday'
require 'json'

module LearnTest
  class Client
    SERVICE_URL = ENV.fetch('IRONBROKER_URL', 'http://ironbroker-v2.flatironschool.com').freeze

    def initialize(service_url = SERVICE_URL)
      @conn = Faraday.new(url: service_url) do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end

    def post_results(endpoint, result)
      @conn.post do |req|
        req.url(endpoint)
        req.headers['Content-Type'] = 'application/json'
        req.body = JSON.dump(result)
      end

      true
    rescue Faraday::Error
      false
    end
  end
end
