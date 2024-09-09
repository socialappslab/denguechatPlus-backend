# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class Inspection < Dry::Validation::Contract
          params do
            required(:has_water).filled(:bool)
            required(:was_chemically_treated).filled(:bool)
            required(:breeding_site_type_id).filled(:integer)
            required(:elimination_method_type_id).filled(:integer)
            required(:water_source_type_id).filled(:integer)
            required(:lid_type).filled(:string)
            required(:quantity_founded).filled(:integer, gt?: 1, lt?: 100)
            optional(:code_reference).filled(:string)
            optional(:container_test_result).filled(:string)
            optional(:tracking_type_required).filled(:string)
            optional(:created_by_id).filled(:integer)
            optional(:treated_by_id).filled(:integer)
            optional(:water_source_other).filled(:string)
            optional(:lid_type_other).filled(:string)
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
