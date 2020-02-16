module Powerbi
  class Auth
    attr_accessor :connection
    attr_reader :response

    def initialize
      @connection ||= Faraday.new 'https://login.microsoftonline.com/' do |builder|
        builder.request :url_encoded
        builder.response :logger
        builder.response :json, content_type: /\bjson/
        builder.adapter Faraday.default_adapter
      end
      @reponse = nil
    end

    def response_body
      response = auth_connect_post

      {
        expires_in: response.body['expires_in'],
        access_token: response.body['access_token'],
      }
    end

    private

      def auth_connect_post
        connection.post do |req|
          req.headers['Accept'] = 'application/json'
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          req.url "/#{ENV['ACTIVE_DIRECTORY_TENANT_ID']}/oauth2/v2.0/token"
          req.body = {
            grant_type: 'client_credentials',
            client_id: ENV['ACTIVE_DIRECTORY_CLIENT_ID'],
            client_secret: ENV['ACTIVE_DIRECTORY_CLIENT_SECRET'],
            scope: 'https://analysis.windows.net/powerbi/api/.default'
          }
        end
      end
  end
end
