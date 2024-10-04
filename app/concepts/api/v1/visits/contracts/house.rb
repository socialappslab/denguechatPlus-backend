# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class House < Dry::Validation::Contract
          params do
            required(:address).filled(:string)
            optional(:latitude).filled(:float)
            optional(:longitude).filled(:float)
            optional(:notes).filled(:string)
            optional(:reference_code).filled(:string)
            required(:house_block_id).filled(:integer)
            optional(:special_place_id).filled(:integer)
          end

          rule(:house_block_id) do
            unless HouseBlock.exists?(id: value)
              key(:house_block_id_on_house).failure(text: "The house block with id: #{value} does not exist",
                                                    predicate: :not_exists?)
            end
          end

          rule(:special_place_id) do
            if values[:special_place_id] && !SpecialPlace.exists?(id: value)
              key(:special_place_id_on_house).failure(text: "The Special Place with id: #{value} does not exist",
                                                      predicate: :not_exists?)
              end
          end
        end
      end
    end
  end
end
