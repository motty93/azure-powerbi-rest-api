module ActiveDirectry
  class Client
    attr_accessor :client

    def initialize
      @client ||= OAuth2::Client.new(
        ENV['ACTIVE_DIRECTORY_CLIENT_ID'],
        ENV['ACTIVE_DIRECTORY_CLIENT_SECRET'],
        site: 'https://login.microsoftonline.com',
        authorize_url: "/#{ENV['ACTIVE_DIRECTORY_TENANT_ID']}/oauth2/authorize",
        token_url: "/#{ENV['ACTIVE_DIRECTORY_TENANT_ID']}/oauth2/token",
        resource: 'https://analysis.windows.net/powerbi/api/'
      )
    end

    private

      def new_state
        session[:state] = SecureRandom.hex(8)
      end

      def new_nonce
        session[:nonce] = SecureRandom.hex(8)
      end

      def get_token_opts
        {
          redirect_uri: ENV['OAUTH_CALLBACK_URL'],
          scope: 'openid https://analysis.windows.net/powerbi/api/ Report.ReadWrite'
        }
      end
  end
end
