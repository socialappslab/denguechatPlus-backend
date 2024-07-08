# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Contracts
        class Create < Dry::Validation::Contract

          def self.kall(...)
            new.call(...)
          end

          params do
            required(:name).filled(:string)
          end
        end
      end
    end
  end
end
