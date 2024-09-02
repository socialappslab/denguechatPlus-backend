require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class Update < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              config.validate_keys = true
              required(:id).filled(:integer)
              optional(:phone).filled(:integer)
              optional(:password).filled(:string, min_size?: Constants::User::PASSWORD_MIN_LENGTH)
              optional(:username).filled(:string)
              optional(:role_ids).filled(:array)
              optional(:status).filled(:string, included_in?: %w[pending active inactive locked])
              optional(:user_profile_attributes).hash do
                optional(:first_name).filled(:string)
                optional(:last_name).filled(:string)
                optional(:gender).filled(:integer)
                optional(:points).filled(:integer)
                optional(:city_id).filled(:integer)
                optional(:neighborhood_id).filled(:integer)
                optional(:organization_id).filled(:integer)
                optional(:team_id).filled(:integer)
                optional(:timezone).filled(:string)
                optional(:language).filled(:string)
                optional(:email).filled(:string)
              end
            end

            rule(:id) do
              if values[:id] && !UserProfile.exists?(id: values[:id])
                key(:id).failure(text: 'The user not exists', predicate: :not_exists?)
              end
            end

            rule(:role_ids) do
              if values[:role_ids] && !Role.exists?(id: values[:role_ids])
                key(:role_ids).failure(text: 'The rol not exists', predicate: :not_exists?)
              end
            end

            rule(:user_profile_attributes) do
              if value && value[:email] && UserProfile.where.not(id: values[:id]).exists?(['LOWER(email) = ?', value[:email].downcase])
                key(:email).failure(text: :user_email_unique?, predicate: :user_email_unique?)
              end

              if value && value[:neighborhood_id] && !Neighborhood.exists?(id: value[:neighborhood_id])
                key(:neighborhood_id).failure(text: 'neighborhood not exists', predicate: :not_exists?)
              end

              if value && value[:city_id] && !City.exists?(id: value[:city_id])
                key(:city_id).failure(text: 'city not exists', predicate: :not_exists?)
              end

              if value && value[:organization_id] && !Organization.exists?(id: value[:organization_id])
                key(:organization_id).failure(text: 'organization not exists', predicate: :not_exists?)
              end

              if value && value[:team_id] && !Team.exists?(id: value[:team_id])
                key(:team_id).failure(text: "The brigade with id #{value[:team_id]} not exists", predicate: :not_exists?)
              end


            end

            rule(:phone) do
              if result.success?
                if !values[:phone].nil? && values[:phone].blank?
                  key(:phone).failure(text: "Phone can't be null", predicate: :credentials_wrong?)
                elsif values[:phone] && UserAccount.where.not(user_profile_id: values[:id]).exists?(phone: values[:phone])
                  key(:phone).failure(text: 'The phone already use by other user', predicate: :user_phone_unique?)
                end
              end
            end

            rule(:username) do
              if result.success?
                if !values[:username].nil? && values[:username].blank?
                  key(:username).failure(text: "Username can't be null", predicate: :credentials_wrong?)
                elsif values[:username] && UserAccount.where.not(user_profile_id: values[:id]).exists?(username: value.downcase)
                  key(:username).failure(text: 'The username already used by other user', predicate: :user_username_unique?)
                end
              end
            end



          end
        end
      end
    end
  end
end
