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
        put 'change_team/', on: :collection, action: :change_team
        member do
          put 'change_status'
        end
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
      resources :special_places do
        collection do
          delete :destroy
        end
      end
      resources :houses, only: %i[index] do
        collection do
          get :list_to_visit
        end
      end
      resources :house_blocks, only: %i[index]
      resources :visits, only: %i[create]
      resources :questionnaires, only: %i[current] do
        collection do
          get :current
        end
      end
      resources :posts, only: %i[create show] do
        member do
          post 'like'
        end
        resources :comments, only: %i[index create show] do
          member do
            post 'like'
          end
        end
      end
      resources :comments, only: [] do
        resources :likes, only: %i[create destroy]
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
      resources :neighborhoods, only: %i[show index] do
        get '/', to: 'neighborhoods#list_by_iquitos_location', on: :collection
        get '/', to: 'neighborhoods#show', on: :member
      end
      resources :cities, only: %i[show index] do
        get '/', to: 'cities#list_by_country_and_state_assumption', on: :collection
        get '/', to: 'cities#show_by_country_and_state_assumption', on: :member
      end

      namespace :public do
        resources :countries, only: %i[show index] do
          resources :states, only: %i[show index] do
            resources :cities, only: %i[show index] do
              resources :neighborhoods, only: %i[show index] do
                resources :wedges, only: %i[show index]
              end
            end
          end
        end
        resources :organizations, only: %i[index show], controller: '/api/v1/organizations'
        resources :cities, only: %i[show index] do
          get '/', to: '/api/v1/cities#list_by_country_and_state_assumption', on: :collection
          get '/', to: '/api/v1/cities#show_by_country_and_state_assumption', on: :member
        end
        resources :neighborhoods, only: %i[show index] do
          get '/', to: '/api/v1/neighborhoods#list_by_iquitos_location', on: :collection
          get '/', to: '/api/v1/neighborhoods#show', on: :member
        end
      end

      get 'get_last_params', controller: 'get_last_params', action: 'index'
      get 'get_address', controller: 'get_address', action: 'find_address'
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
