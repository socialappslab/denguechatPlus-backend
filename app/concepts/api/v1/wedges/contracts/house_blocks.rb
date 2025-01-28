# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Contracts
        class HouseBlocks < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            required(:id).filled(:integer)

            optional(:page).maybe(:hash) do
              optional(:is_cursor).maybe(:bool)
              optional(:size).maybe(:integer)
            end

            optional(:sort).maybe(:string)
          end
        end
      end
    end
  end
end
