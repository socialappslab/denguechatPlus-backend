# frozen_string_literal: true

module Api
  module V1
    module GetAddress
      module Contracts
        class FindAddress < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            required(:latitude).filled(:float)
            required(:longitude).filled(:float)
          end
        end
      end
    end
  end
end
