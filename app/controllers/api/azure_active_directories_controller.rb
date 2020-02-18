class Api::AzureActiveDirectoriesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :powerbi_auth, only: :callback

  def authorization
    redirect_to api_azure_active_directories_callback_path
  end

  def callback
    auth_params = @auth.response_body
    session[:access_token] = auth_params[:access_token]
    session[:expires_in] = auth_params[:expires_in]

    client = Powerbi::Client.new(auth_params[:access_token])
    powerbi_response = client.get_report
    @report = JSON.parse(powerbi_response.body).symbolize_keys
  end

  def generate_token
    client = Powerbi::Client.new(session[:access_token])
    powebi_response = client.post_generate_token
    @json = JSON.parse(powebi_response.body).symbolize_keys
  end

  private

    def powerbi_auth
      @auth = Powerbi::Auth.new
    end
end
