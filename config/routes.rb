# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'


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
        put 'update_password/', on: :collection, action: :update_password
        member do
          put 'change_status'
        end
      end
      resources :roles, only: %i[index update create]
      resources :permissions, only: %i[index show]
      namespace :users do
        resource :session, only: %i[create destroy], controller: :sessions do
          post 'refresh_token'
          post 'validate_code'
        end
        resource :accounts, only: %i[create], controller: :accounts do
          collection do
            post 'confirm_account'
          end
        end
      end
      resources :recovery_password, only: [] do
        collection do
          post 'validate_phone', to: 'recovery_password#validate_phone'
          post 'validate_code', to: 'recovery_password#validate_code'
          post 'new_password', to: 'recovery_password#new_password'
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
      resources :houses, only: %i[index update] do
        collection do
          get :list_to_visit
          get :orphan_houses
        end
      end
      resources :house_blocks, only: %i[index update create]
      resources :visits, only: %i[create index show update destroy] do
        resources :inspections, only: %i[index show update]
        member do
          get :download_information
        end
      end
      resources :questionnaires, only: %i[current] do
        collection do
          get :current
        end
      end
      resources :posts do
        member do
          post 'like'
        end
        resources :comments do
          member do
            post 'like'
          end
        end
      end
      resources :points, only: %i[accumulated_points] do
        collection do
          get :accumulated_points
          get :ranking
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
      resources :wedges, except: :index do
        get '/', to: 'public/wedges#index', on: :collection
        get 'house_blocks', to: 'wedges#house_blocks', on: :member
      end
      resources :reports do
        get :house_status, on: :collection, action: :house_status
        get :brigadists_performance, on: :collection, action: :brigadists_performance
        get :tariki_houses, on: :collection, action: :tariki_houses
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
        resources :wedges, only: %i[show index]
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

      namespace :admin do
        resources :users do
          put :change_status, controller: '/api/v1/users', method: 'change_status', on: :member
        end
      end

      get 'get_last_params', controller: 'get_last_params', action: 'index'
      get 'get_address', controller: 'get_address', action: 'find_address'
      delete 'users/delete_account', to: 'users#delete_account'


    end
  end

  namespace :web do
    resources :change_images, only: [] do
      collection do
        get :question_images
        get :option_images
      end
      member do
        post :update_image
        post :update_image_question
      end
    end
    resources :sync_logs, only: [:show, :index]
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

  # match '*unmatched', to: 'application#route_not_found', via: :all
end
