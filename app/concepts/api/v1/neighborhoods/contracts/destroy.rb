# frozen_string_literal: true

module Api
  module V1
    module Neighborhoods
      module Contracts
        class Destroy < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            required(:neighborhoods_ids).filled(:array).each(:integer)
          end
        end
      end
    end
  end
end
