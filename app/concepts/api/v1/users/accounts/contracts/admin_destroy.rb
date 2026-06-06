# frozen_string_literal: true

require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class AdminDestroy < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              required(:id).filled(:integer)
            end
          end
        end
      end
    end
  end
end
