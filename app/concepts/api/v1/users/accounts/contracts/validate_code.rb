require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class ValidateCode < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end
            params do
              required(:code).filled(:string, min_size?: 6)
              required(:phone).filled(:string)
              required(:username).filled(:string)
            end
          end
        end
      end
    end
  end
end
