# frozen_string_literal: true

module Api
  module V1
    module Countries
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            optional(:name).filled(:string)
            optional(:states_attributes).array(:hash) do
              optional(:id).filled(:integer)
              optional(:_destroy).filled(:integer)
            end
          end

          rule(:states_attributes).each do
            if value[:id] && State.exists?(id: values[:id], discarded_at: nil)
              key(:state_id).failure('state already exists in this country')
            end
          end

        end
      end
    end
  end
end
