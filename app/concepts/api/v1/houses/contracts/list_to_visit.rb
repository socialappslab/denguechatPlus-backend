# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Contracts
        class ListToVisit < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
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
