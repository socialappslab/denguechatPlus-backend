# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'health' => 'health_checks#show', as: :health_check
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index update] do
        get 'me', on: :collection, action: :show_current_user
      end
      resources :roles, only: %i[index update create]
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
              end
            end
          end
        end
      end
    end
  end
end
