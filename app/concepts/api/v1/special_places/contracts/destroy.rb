# frozen_string_literal: true

module Api
  module V1
    module SpecialPlaces
      module Contracts
        class Destroy < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            required(:special_place_ids).filled(:array).each(:integer)
          end
        end
      end
    end
  end
end
