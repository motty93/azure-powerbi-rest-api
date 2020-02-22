module Powerbi
  class Client
    BASE_URL = "https://api.powerbi.com/"
    attr_accessor :connection

    def initialize(token)
      @connection ||= Faraday.new BASE_URL do |builder|
        builder.request :url_encoded
        builder.request :oauth2, token, token_type: :bearer
        builder.request :json # NoMethodError (undefined method `bytesize' for {"accessLevel"=>"View"}:Hash)対策
        builder.response :logger
        builder.adapter Faraday.default_adapter
      end
    end

    def get_report(id = ENV['REPORT_ID'])
      connection.get "/v1.0/myorg/groups/#{ENV['GROUP_ID']}/reports/#{id}"
    end

    def post_generate_token(id = ENV['REPORT_ID'])
      connection.post do |req|
        req.headers['Content-Type'] = 'application/json'
        req.url "/v1.0/myorg/groups/#{ENV['GROUP_ID']}/reports/#{id}/GenerateToken"
        req.body = {
          accessLevel: 'View'
        }
      end
    end
  end
end
