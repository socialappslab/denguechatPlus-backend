# frozen_string_literal: true

module Api
  module V1
    module SpecialPlaces
      module Contracts
        class Index < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            optional(:filter).maybe(:hash) do
              optional(:name).maybe(:string)
              optional(:name_es).maybe(:string)
              optional(:name_en).maybe(:string)
              optional(:name_pt).maybe(:string)
              optional(:status).maybe(:string, included_in?: %w[active inactive all])
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
