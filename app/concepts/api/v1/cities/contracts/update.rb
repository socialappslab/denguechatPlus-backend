# frozen_string_literal: true

module Api
  module V1
    module Cities
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            optional(:name).filled(:string)
            optional(:neighborhoods_attributes).array(:hash) do
              optional(:id).filled(:integer)
              optional(:name).filled(:string)
              optional(:_destroy).filled(:integer)
            end
          end

          rule(:neighborhoods_attributes).each do
            if value[:name] && Neighborhood.exists?(name: value[:name].downcase, discarded_at: nil)
              key.failure('Neighborhood already exists in this neighborhood')
            end
          end

        end
      end
    end
  end
end
