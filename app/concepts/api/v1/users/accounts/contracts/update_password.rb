require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class UpdatePassword < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              required(:current_user).value(type?: UserAccount)
              required(:current_password).filled(:string, min_size?: Constants::User::PASSWORD_MIN_LENGTH)
              required(:new_password).filled(:string, min_size?: Constants::User::PASSWORD_MIN_LENGTH)
              required(:confirm_password).filled(:string, min_size?: Constants::User::PASSWORD_MIN_LENGTH)
            end

            rule(:current_user) do
              unless values[:current_user]&.authenticate(values[:current_password]&.downcase)
                key(:password).failure(text: "the current password is invalid", predicate: :not_found?)
              end
            end

            rule(:new_password) do
              unless values[:new_password] == values[:confirm_password]
                key(:new_password).failure(text: "the new password don't match with confirm_password", predicate: :not_found?)
              end
            end

          end
        end
      end
    end
  end
end
