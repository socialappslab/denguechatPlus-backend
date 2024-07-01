# frozen_string_literal: true

Rails.application.routes.draw do
  resources :organizations
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :users do
        resource :session, only: %i[create destroy], controller: :sessions
        resource :accounts, only: %i[create], controller: :accounts do
          collection do
            post 'confirm_account'
          end
        end
      end
      resources :organizations
    end
  end
end
