# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class Create < Dry::Validation::Contract

          def self.kall(...)
            new.call(...)
          end

          params do
            required(:answers).filled(:array).each(:hash)
            required(:host).filled(:string)
            required(:visit_permission).filled(:bool)
            required(:visited_at).filled(:date_time)
            optional(:house_id).filled(:integer)
            required(:questionnaire_id).filled(:integer)
            optional(:team_id).filled(:integer)
            optional(:user_account_id).filled(:integer)
            optional(:notes)

            optional(:inspections).filled(:array)

            optional(:house).filled(:hash)

          end

          rule(:inspections) do
            if value && !value.empty?
              value.each do |inspection|
                unless BreedingSiteType.exists?(id: inspection['breeding_site_type_id'])
                  key(:breeding_site_type_id).failure(text: "The BreedingSiteType does not exist",
                                                      predicate: :not_exists?)
                end

                unless EliminationMethodType.exists?(id: inspection['elimination_method_type_id'])
                  key(:elimination_method_type_id).failure(text: "The EliminationMethodType does not exist",
                                                           predicate: :not_exists?)
                end

                unless WaterSourceType.exists?(id: inspection['water_source_type_id'])
                  key(:water_source_type_id).failure(text: "The WaterSourceType does not exist",
                                                     predicate: :not_exists?)
                end

                unless ContainerProtection.exists?(id: inspection['container_protection_id'])
                  key(:container_protection_id).failure(text: "The ContainerProtection does not exist",
                                                     predicate: :not_exists?)
                end

                unless inspection['type_content_id'].all? {|id| TypeContent.exists?(id: id)}
                  key(:container_protection_id).failure(text: "The TypeContent does not exist",
                                                        predicate: :not_exists?)
                end

                unless inspection.has_key?('has_water')
                  key(:has_water).failure(text: "has_water is required",
                                                        predicate: :filled?)
                end

                unless inspection.has_key?('was_chemically_treated')
                  key(:was_chemically_treated).failure(text: "was_chemically_treated is required",
                                          predicate: :filled?)
                end

                if inspection.has_key?('quantity_founded') && !inspection['quantity_founded'].nil?
                  if inspection['quantity_founded'].to_i <= 0
                    key(:quantity_founded).failure(text: "quantity_founded should be major than 0",
                                                         predicate: :gteq?)
                  end
                end

              end
            end
          end


          rule(:house) do
            if value && !value.empty?
              if !value.has_key?('address') || value['address']&.empty?
                key(:address).failure(text: "address is required",
                                      predicate: :filled?)
              end

              if !value.has_key?('latitude') && value.has_key?('longitude')
                key(:latitude).failure(text: "latitude is required if you pass longitude",
                                       predicate: :filled?)
              end

              if !value.has_key?('longitude') && value.has_key?('latitude')
                key(:latitude).failure(text: "longitude is required if you pass latitude",
                                       predicate: :filled?)
              end

              unless HouseBlock.exists?(id: value['house_block_id'])
                key(:house_block_id).failure(text: "The HouseBlock does not exist",
                                             predicate: :not_exists?)
              end

              if value.has_key?('special_place_id') && !SpecialPlace.exists?(id: value['special_place_id'])
                key(:special_place_id).failure(text: "The SpecialPlace does not exist", predicate: :not_exists?)
              end
            end
          end

          rule(:house_id) do
            house_exists = ::House.find_by(id: value).present?
            if !house_exists && !values[:house]
              key(:house_id).failure(text: 'The house not exists, you need to send a house obj with the new house data',
                                     predicate: :not_exists?)
            end
          end

          rule(:questionnaire_id) do
            unless Questionnaire.kept.exists?(id: value)
              key(:questionnaire_id).failure(text: "The Questionnaire with id: #{value} does not exist",
                                    predicate: :not_exists?)
            end
          end

          rule(:user_account_id) do
            unless UserAccount.kept.exists?(id: value)
              key(:user_account_id).failure(text: "The UserAccount with id: #{value} does not exist",
                                    predicate: :not_exists?)
            end
          end
        end
      end
    end
  end
end
