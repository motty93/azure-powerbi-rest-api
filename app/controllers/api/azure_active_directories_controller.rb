class Api::AzureActiveDirectoriesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :ad_oauth2_client, only: %i(authorization callback)

  def authorization
    redirect_to @client.auth_code.authorize_url(
      reponse_type: 'code',
      redirect_uri: ENV['OAUTH_CALLBACK_URL'],
      response_mode: 'query',
      state: new_state,
    )
  end

  def callback
    # TODO: access_token取得できてるけど、これじゃ駄目な可能性が… -> faradayへ変更
    token = @client.auth_code.get_token(params[:code], get_token_opts)

    conn = Faraday.new 'https://api.powerbi.com/v1.0/myorg/groups/' do |builder|
             builder.request :oauth2, token.token, token_type: :bearer
             builder.request :url_encoded
             builder.response :logger
             builder.response :json, content_type: /\bjson/
             builder.adapter Faraday.default_adapter
           end

    # response = token.get("https://api.powerbi.com/v1.0/myorg/groups/#{ENV['GROUP_ID']}/reports", { access_token: token.token }).parsed

    # res = conn.post "/#{ENV['ACTIVE_DIRECTORY_TENANT_ID']}/oauth2/authorize" do |req|
    #         # req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    #         req.body = {
    #           grant_type: 'authorization_code',
    #           client_id: ENV['ACTIVE_DIRECTORY_CLIENT_ID'],
    #           code: params[:code],
    #           redirect_uri: ENV['OAUTH_CALLBACK_URL'],
    #           resource: 'https://analysis.windows.net/powerbi/api/',
    #           client_secret: ENV['ACTIVE_DIRECTORY_CLIENT_SECRET']
    #         }
    #       end
  end

  private

    def ad_oauth2_client
      @client = OAuth2::Client.new(
                  ENV['ACTIVE_DIRECTORY_CLIENT_ID'],
                  ENV['ACTIVE_DIRECTORY_CLIENT_SECRET'],
                  {
                    site: "https://login.microsoftonline.com",
                    authorize_url: "/#{ENV['ACTIVE_DIRECTORY_TENANT_ID']}/oauth2/authorize",
                    token_url: "/#{ENV['ACTIVE_DIRECTORY_TENANT_ID']}/oauth2/token",
                    resource: "https://analysis.windows.net/powerbi/api/",
                  }
                )
    end

    def new_state
      session[:state] = SecureRandom.hex(8)
    end

    def new_nonce
      session[:nonce] = SecureRandom.hex(8)
    end

    def get_token_opts
      {
        redirect_uri: ENV['OAUTH_CALLBACK_URL'],
      }
    end
end
