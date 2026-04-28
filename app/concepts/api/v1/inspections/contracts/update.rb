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
            optional(:elimination_method_type_ids).maybe(:array)
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
              key.failure(text: 'The inspection does not exist', predicate: :not_exists?)
            end
          end

          rule(:breeding_site_type_id) do
            unless BreedingSiteType.exists?(id: value)
              key.failure(text: 'The BreedingSiteType does not exist', predicate: :not_exists?)
            end
          end

          rule(:elimination_method_type_ids) do
            if key? && !all_ids_exist?(EliminationMethodType, value)
              key.failure(text: 'The EliminationMethodType does not exist', predicate: :not_exists?)
            end
          end

          rule(:water_source_type_ids) do
            if key? && !all_ids_exist?(WaterSourceType, value)
              key.failure(text: 'The WaterSourceType does not exist', predicate: :not_exists?)
            end
          end

          rule(:container_protection_ids) do
            if key? && !all_ids_exist?(ContainerProtection, value)
              key.failure(text: 'The ContainerProtection does not exist', predicate: :not_exists?)
            end
          end

          rule(:type_content_ids) do
            if key? && (value.nil? || !value.all? { |id| TypeContent.exists?(id:) })
              key.failure(text: 'The TypeContent does not exist', predicate: :not_exists?)
            end
          end

          private

          def all_ids_exist?(model, ids)
            return true if ids.blank?

            Array(ids).all? { |id| model.exists?(id:) }
          end
        end
      end
    end
  end
end
