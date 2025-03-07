# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Contracts
        class Index < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            optional(:filter).maybe(:hash) do
              optional(:name).maybe(:string)
              optional(:neighborhood_id).maybe(:integer)
              optional(:sector_id).maybe(:integer)
              optional(:sector_name).maybe(:string)
            end

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
