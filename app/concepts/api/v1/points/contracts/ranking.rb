# frozen_string_literal: true
require 'ostruct'

module Api
  module V1
    module Points
      module Contracts
        class Ranking < Dry::Validation::Contract

          def self.kall(...)
            new.call(...)
          end

          params do
            optional(:filter).maybe(:hash) do
              optional(:type).filled(:string, included_in?: %w[teams users])
              optional(:limit).filled(:integer, gteq?: 1)
              optional(:from_date).filled(:date)
              optional(:to_date).filled(:date)
            end
            optional(:sort).maybe(:string)
            optional(:order).maybe(:string, included_in?: %w[asc desc])
          end

        end
      end
    end
  end
end
