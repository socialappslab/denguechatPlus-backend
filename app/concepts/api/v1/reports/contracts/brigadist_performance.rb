# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Contracts
        class BrigadistPerformance < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            optional(:filter).maybe(:hash) do
              optional(:name).maybe(:string)
              required(:team_id).maybe(:integer)
              optional(:wedge_id).maybe(:integer)
              optional(:neighborhood_id).maybe(:integer)
            end

            optional(:page).maybe(:hash) do
              optional(:is_cursor).maybe(:bool)
            end

            optional(:sort).maybe(:string)
          end
        end
      end
    end
  end
end
