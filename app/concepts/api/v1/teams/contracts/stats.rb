# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Contracts
        class Stats < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            optional(:from).filled(:date)
            optional(:to).filled(:date)
          end

          rule(:from, :to) do
            next unless values[:from] && values[:to]
            next unless values[:from] > values[:to]

            key(:from).failure(text: 'from must be before or equal to to', predicate: :invalid_date_range?)
          end
        end
      end
    end
  end
end
