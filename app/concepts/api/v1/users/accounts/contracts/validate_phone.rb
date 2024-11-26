require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class ValidatePhone < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              required(:phone).filled(:string)
              required(:username).filled(:string)
            end

            rule(:phone) do
              if value.to_s.length < 9
                key.failure(text: "must have at least 9 digits", predicate: :min_size?)
              end
              # unless value.match?(/\A\d+\z/)
              #   key.failure(text: "must contain only numbers", predicate: :format?)
              # end
              if values[:username] && values[:phone]
                unless UserAccount.find_by(username: values[:username], phone: values[:phone])
                  key(:user_name_and_phone).failure(text: "does not match the user's registered phone number", predicate: :not_found?)
                end
              end
            end

            rule(:username) do
              if value.length < 3
                key.failure("must be at least 3 characters long")
              end

              if value.match?(/[^a-zA-Z0-9_]/)
                key.failure("can only contain letters, numbers, and underscores")
              end
            end
          end
        end
      end
    end
  end
end
