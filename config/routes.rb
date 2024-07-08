# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'health' => 'health_checks#show', as: :health_check
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
      resources :organizations do
        collection do
          delete :destroy
        end
      end
      resources :locations, only: %i[index]

      namespace :admin do
        resources :users do
          member do
            put 'change_status'
          end
        end
        resources :teams
      end
    end
  end
end
