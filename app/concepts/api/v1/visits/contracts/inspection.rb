# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class Inspection < Dry::Validation::Contract
          params do
            required(:breeding_site_type_id).filled(:integer)
            optional(:elimination_method_type_id).filled(:integer)
            optional(:water_source_type_id).filled(:integer)
            optional(:code_reference).filled(:string)
            optional(:photo_id).filled(:string)
            required(:has_water).filled(:bool)
            optional(:was_chemically_treated).filled(:string)
            optional(:container_test_result).filled(:string)
            optional(:water_source_other).filled(:string)
            optional(:container_protection_id).filled(:integer)
            optional(:other_protection).filled(:string)
            required(:type_content_id).filled(:array)
            required(:quantity_founded).filled(:integer, gteq?: 1, lteq?: 100)
          end

          rule(:breeding_site_type_id) do
            unless BreedingSiteType.exists?(id: value)
              key(:breeding_site_type_id).failure(text: "The BreedingSiteType with id: #{value} does not exist",
                                                  predicate: :not_exists?)
            end
          end

          rule(:elimination_method_type_id) do
            unless EliminationMethodType.exists?(id: value)
              key(:elimination_method_type_id).failure(text: "The EliminationMethodType with id: #{value} does not exist",
                                                       predicate: :not_exists?)
            end
          end

          rule(:water_source_type_id) do
            unless WaterSourceType.exists?(id: value)
              key(:water_source_type_id).failure(text: "The WaterSourceType with id: #{value} does not exist",
                                                 predicate: :not_exists?)
            end
          end
        end
      end
    end
  end
end
