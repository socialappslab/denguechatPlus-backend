# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            optional(:id)
            optional(:breeding_site_type_id).filled(:integer)
            optional(:treated_by_id).filled(:integer)

            optional(:code_reference).maybe(:string)
            optional(:container_test_result).maybe(:string)
            optional(:has_water).maybe(:bool)
            optional(:lid_type).maybe(:string)
            optional(:location).maybe(:string)
            optional(:lid_type_other).maybe(:string)
            optional(:other_elimination_method).maybe(:string)
            optional(:other_protection).maybe(:string)
            optional(:was_chemically_treated).maybe(:string)
            optional(:water_source_other).maybe(:string)

            optional(:container_protection_ids).maybe(:array)
            optional(:elimination_method_type_id).maybe(:integer)
            optional(:water_source_type_id).maybe(:integer)
            optional(:water_source_type_ids).maybe(:array)
            optional(:type_content_ids).maybe(:array)

            optional(:delete_photo).maybe(:bool)
            optional(:photo)

            optional(:page).maybe(:hash) do
              optional(:is_cursor).maybe(:bool)
            end

            optional(:sort).maybe(:string)
          end

          rule(:id) do
            unless Inspection.exists?(id: value)
              key.failure(text: "The inspection does not exist", predicate: :not_exists?)
            end
          end

          rule(:breeding_site_type_id) do
            unless BreedingSiteType.exists?(id: value)
              key.failure(text: "The BreedingSiteType does not exist", predicate: :not_exists?)
            end
          end

          rule(:elimination_method_type_id) do
            if key?
              unless EliminationMethodType.exists?(id: value)
                key.failure(text: "The EliminationMethodType does not exist", predicate: :not_exists?)
              end
            end
          end

          rule(:water_source_type_ids) do
            if key?
              unless WaterSourceType.exists?(id: value)
                key.failure(text: "The WaterSourceType does not exist", predicate: :not_exists?)
              end
            end
          end

          rule(:container_protection_ids) do
            if key?
              unless ContainerProtection.exists?(id: value)
                key.failure(text: "The ContainerProtection does not exist", predicate: :not_exists?)
              end
            end
          end

          rule(:type_content_ids) do
            if key?
              if value.nil?
                key.failure(text: "The TypeContent does not exist", predicate: :not_exists?)
              elsif !value.all? { |id| TypeContent.exists?(id: id) }
                key.failure(text: "The TypeContent does not exist", predicate: :not_exists?)
              end
            end
          end
        end
      end
    end
  end
end
