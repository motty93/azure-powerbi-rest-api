module Powerbi
  class Client
    BASE_URL = "https://api.powerbi.com/"
    attr_accessor :connection

    def initialize(token)
      @connection ||= Faraday.new BASE_URL do |builder|
        builder.request :url_encoded
        builder.request :oauth2, token, token_type: :bearer
        builder.response :logger
        builder.adapter Faraday.default_adapter
      end
    end

    def get_report(id = ENV['REPORT_ID'])
      connection.get "/v1.0/myorg/groups/#{ENV['GROUP_ID']}/reports/#{id}"
    end
  end
end
