# frozen_string_literal: true

module Api
  module V1
    module SpecialPlaces
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            optional(:name).filled(:string)
            optional(:name_es).filled(:string)
            optional(:name_pt).filled(:string)
            optional(:name_en).filled(:string)
          end
        end
      end
    end
  end
end
