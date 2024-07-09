require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class Create < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              optional(:phone).filled(:string)
              optional(:username).filled(:string)
              optional(:email).filled(:string)
              required(:password).filled(:string, min_size?: Constants::User::PASSWORD_MIN_LENGTH)

              required(:user_profile).hash do
                required(:first_name).filled(:string)
                required(:last_name).filled(:string)
                required(:gender).filled(:integer)
                required(:country).filled(:string)
                required(:city).filled(:string)
                required(:language).filled(:string)
                required(:timezone).filled(:string)
              end
            end

            rule(:email) do
              if values[:email]
                if UserAccount.exists?(['LOWER(email) = ?', values[:email].downcase])
                  key(:email).failure(text: :user_email_unique?,  predicate: :user_email_unique?)
                end
              end
            end


            rule(:phone) do
              if values[:phone].nil? && values[:username].nil?
                key(:phone).failure(text: :user_credential_requirement, predicate: :credentials_wrong?)
              elsif values[:phone] && UserAccount.exists?(phone: values[:phone])
                key.failure(text: :user_phone_unique?, predicate: :user_phone_unique?)
              end
            end

            rule(:username) do
              if values[:username].nil? && values[:phone].nil?
                key(:username).failure(text: :user_credential_requirement, predicate: :credentials_wrong?)
              elsif values[:username] && UserAccount.exists?(username: value)
                key.failure(text: :user_username_unique?, predicate: :user_username_unique?)
              end
            end

          end
        end
      end
    end
  end
end
