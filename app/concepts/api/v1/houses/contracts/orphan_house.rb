# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Contracts
        class OrphanHouse < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            optional(:filter).maybe(:hash) do
              optional(:country_id).maybe(:integer)
              optional(:state_id).maybe(:integer)
              optional(:city).maybe(:integer)
              optional(:neighborhood_id).maybe(:integer)
              optional(:wedge_id).maybe(:integer)
              optional(:house_block_id).maybe(:integer)
              optional(:reference_code).maybe(:string)
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
