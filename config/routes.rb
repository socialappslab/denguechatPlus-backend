# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq::Web.use Rack::Session::Cookie, secret: ENV.fetch("SIDEKIQ_WEBTOKEN")

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'health' => 'health_checks#show', as: :health_check
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index update show] do
        get 'me', on: :collection, action: :show_current_user
        get 'get_by_id/:id', on: :collection, action: :show
      end
      resources :roles, only: %i[index update create]
      resources :permissions, only: %i[index show]
      namespace :users do
        resource :session, only: %i[create destroy], controller: :sessions do
          post 'refresh_token'
        end
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
      resources :special_places
      resources :houses, only: %i[index]
      resources :house_blocks, only: %i[index]
      resources :visits, only: %i[create]

      namespace :admin do
        resources :users do
          member do
            put 'change_status'
          end
        end
        resources :teams do
          collection do
            delete :destroy
          end
        end
        resources :countries do
          collection do
            delete :destroy
          end
          resources :states do
            collection do
              delete :destroy
            end
            resources :cities do
              collection do
                delete :destroy
              end
              resources :neighborhoods do
                collection do
                  delete :destroy
                end
                resources :wedges, only: :index
              end
            end
          end
        end
      end

      get 'get_last_params', controller: 'get_last_params', action: 'index'
    end
  end

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username_match = ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(username),
      ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_USERNAME', ''))
    )

    password_match = ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(password),
      ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_PASSWORD', ''))
    )

    username_match & password_match
  end

  mount Sidekiq::Web => '/sidekiq'

end
