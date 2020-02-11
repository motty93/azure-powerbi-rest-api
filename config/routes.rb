Rails.application.routes.draw do
  root to: 'homes#index'

  namespace :api do
    namespace :azure_active_directories do
      post :authorization
      get :callback
    end
  end
end
