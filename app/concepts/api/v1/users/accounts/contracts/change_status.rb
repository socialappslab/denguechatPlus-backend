require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class ChangeStatus < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              required(:id).filled(:integer)
              required(:status).maybe(:string, included_in?: %w[pending active inactive locked])
            end
          end
        end
      end
    end
  end
end
