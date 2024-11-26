require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class NewPassword < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              required(:token).filled(:string)
              required(:password).filled(:string, min_size?: Constants::User::PASSWORD_MIN_LENGTH)
              required(:password_confirmation).filled(:string, min_size?: Constants::User::PASSWORD_MIN_LENGTH)
            end

          end
        end
      end
    end
  end
end
