# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:visit_id).filled(:integer)
            required(:breeding_site_type_id).filled(:integer)

            optional(:code_reference).maybe(:string)
            optional(:container_test_result).maybe(:string)
            optional(:location).maybe(:string)
            optional(:other_elimination_method).maybe(:string)
            optional(:other_protection).maybe(:string)
            optional(:was_chemically_treated).maybe(:string)
            optional(:water_source_other).maybe(:string)

            optional(:container_protection_ids).array(:integer)
            optional(:elimination_method_type_ids).array(:integer)
            optional(:type_content_ids).array(:integer)
            optional(:water_source_type_ids).array(:integer)

            optional(:photo)
          end

          rule(:breeding_site_type_id) do
            next if BreedingSiteType.exists?(id: value)

            key.failure(text: 'The BreedingSiteType does not exist', predicate: :not_exists?)
          end

          rule(:container_protection_ids) do
            next if valid_ids?(ContainerProtection, value)

            key.failure(text: 'The ContainerProtection does not exist', predicate: :not_exists?)
          end

          rule(:elimination_method_type_ids) do
            next if valid_ids?(EliminationMethodType, value)

            key.failure(text: 'The EliminationMethodType does not exist', predicate: :not_exists?)
          end

          rule(:type_content_ids) do
            next if valid_ids?(TypeContent, value)

            key.failure(text: 'The TypeContent does not exist', predicate: :not_exists?)
          end

          rule(:water_source_type_ids) do
            next if valid_ids?(WaterSourceType, value)

            key.failure(text: 'The WaterSourceType does not exist', predicate: :not_exists?)
          end

          rule(:location) do
            next if value.nil? || Inspection.locations.key?(value)

            key.failure(text: 'The location is invalid', predicate: :included_in?)
          end

          private

          def valid_ids?(model, ids)
            return true if ids.blank?

            model.where(id: ids).count == ids.uniq.count
          end
        end
      end
    end
  end
end
