# frozen_string_literal: true

module Api
  module V1
    module Permissions
      module Contracts
        class Index < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            optional(:filter).maybe(:hash) do
              optional(:name).maybe(:string)
              optional(:resource).maybe(:string)
            end

            optional(:page).maybe(:hash) do
              optional(:is_cursor).maybe(:bool)
            end

            optional(:sort).maybe(:string)
            optional(:order).maybe(:string, included_in?: %w[asc desc])
          end
        end
      end
    end
  end
end
