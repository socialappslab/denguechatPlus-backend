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
              required(:password).filled(:string, min_size?: Constants::User::PASSWORD_MIN_LENGTH)

              required(:user_profile).hash do
                required(:first_name).filled(:string)
                required(:last_name).filled(:string)
                optional(:gender).filled(:integer)
                required(:city_id).filled(:integer)
                required(:neighborhood_id).filled(:integer)
                required(:organization_id).filled(:integer)
                optional(:timezone).filled(:string)
                optional(:language).filled(:string)
                optional(:email)
              end
            end

            rule(:user_profile) do
              if value[:email].present?
                if UserProfile.exists?(['LOWER(email) = ?', value[:email].downcase])
                  key(:email).failure(text: :user_email_unique?,  predicate: :user_email_unique?)
                end
              end

              if value[:neighborhood_id]
                unless Neighborhood.exists?(id: value[:neighborhood_id])
                  key(:neighborhood_id).failure(text: 'neighborhood not exists',  predicate: :not_exists?)
                end
              end

              if value[:organization_id]
                unless Organization.exists?(id: value[:organization_id])
                  key(:organization_id).failure(text: 'organization not exists',  predicate: :not_exists?)
                end
              end

              if value[:city_id]
                unless City.exists?(id: value[:city_id])
                  key(:city_id).failure(text: 'city not exists',  predicate: :not_exists?)
                end
              end
            end

            rule(:phone) do
              if values[:phone].nil? && values[:username].nil?
                key(:phone).failure(text: :user_credential_requirement, predicate: :credentials_wrong?)
              elsif values[:phone] && UserAccount.exists?(phone: values[:phone])
                key(:phone).failure(text: :user_phone_unique?, predicate: :user_phone_unique?)
              end
            end

            rule(:username) do
              if values[:username].nil? && values[:phone].nil?
                key(:username).failure(text: :user_credential_requirement, predicate: :credentials_wrong?)
              elsif values[:username] && UserAccount.exists?(username: value.downcase)
                key(:username).failure(text: :user_username_unique?, predicate: :user_username_unique?)
              end
            end

          end
        end
      end
    end
  end
end
