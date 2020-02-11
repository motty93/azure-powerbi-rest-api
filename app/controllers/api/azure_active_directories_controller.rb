class Api::AzureActiveDirectoriesController < ApplicationController
  before_action :ad_oauth2_client, only: %i(authorization callback)

  def authorization
    redirect_to @client.auth_code.authorize_url(
      redirect_uri: ENV['OAUTH_CALLBACK_URL']
    )
  end

  def callback
    binding.pry
    token = @client.auth_code.get_token(params[:code], redirect_uri: ENV['OAUTH_CALLBACK_URL'])
  end

  private

    def ad_oauth2_client
      @client = OAuth2::Client.new(
                  ENV['ACTIVE_DIRECTORY_CLIENT_ID'],
                  ENV['ACTIVE_DIRECTORY_CLIENT_SECRET'],
                  {
                    site: "https://login.microsoftonline.com",
                    authorize_url: "/#{ENV['ACTIVE_DIRECTORY_TENANT_ID']}/oauth2/authorize",
                    token_url: "/#{ENV['ACTIVE_DIRECTORY_TENANT_ID']}/oauth2/token"
                  }
                )
    end
end
