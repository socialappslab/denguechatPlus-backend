# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Serializers
        class Show < ApplicationSerializer
          set_type :visit

          attributes :id, :questionnaire_id, :visited_at, :brigadist, :team, :city, :sector, :wedge,
                     :visit_permission, :host, :answers, :notes


          attribute :visited_at do |object|
            @house = object.house
            @city = @house.city
            @sector = @house.neighborhood
            @wedge = @house.wedge
            object.visited_at
          end

          attribute :team do |object|
            {
              id: object.team_id,
              name: object.team.name,
            }
          end

          attribute :brigadist do |object|

            if object.user_account
              {
                id: object.user_account.id,
                fullName: object.user_account.full_name,
              }
            else
              {
                id: nil,
                fullName: 'Usuario eliminado',
              }
            end
          end

          attribute :city do |object|
            {
              id: @city.id,
              name: @city.name,
            }
          end

          attribute :sector do |object|
            {
              id: @sector.id,
              name: @sector.name,
            }
          end

          attribute :wedge do |object|
            {
              id: @wedge.id,
              name: @wedge.name,
            }
          end

          attribute :house do |visit|
            next unless visit.house

            {
              id: visit.house.id,
              reference_code: visit.house.reference_code,
              status: visit.house.status
            }
          end

          attribute :host do |object|
            next unless object.host

            object.host.split(', ')&.map do
              {
                id: object.host,
                value: object.host,
              }
            end
          end

          attribute :modification_history do |visit|
            versions = visit.versions
            next nil unless versions

            modify_by = JSON.parse(visit.versions.last.whodunnit)['full_name'] if visit.versions.last.whodunnit
            {
              lastModified: visit.updated_at,
              modifiedBy: modify_by
            }
          end

          attribute :inspections do |visit|
            next unless visit.inspections.any?

            visit.inspections.map do |inspection|
              {
                id: inspection.id,
                breedingSiteType: {
                  breeding_site_type_id: inspection.breeding_site_type_id,
                  breeding_site_type_name: inspection.breeding_site_type&.name,
                },
                eliminationMethodType: {
                  elimination_method_type_id: inspection.elimination_method_type_id,
                  elimination_method_type_name: inspection.elimination_method_type&.send("name_#{visit.language}"),
                  elimination_method_type_other: inspection.other_elimination_method
                },
                waterSourceType: {
                  water_source_type_id: inspection.water_source_type_id,
                  water_source_type_name: inspection.water_source_type&.name,
                  water_source_other: inspection.water_source_other
                },
                container_protection: {
                  id: inspection.container_protection_id,
                  name: inspection.container_protection&.send("name_#{visit.language}"),
                  container_protection_other: inspection.other_protection
                },
                inspection_type_contents: [
                  inspection.type_contents.map do |content|
                    {
                      id: content.id,
                      name: content.send("name_#{visit.language}")
                    }
                  end
                ],
                has_water: inspection.has_water,
                was_chemically_treated: inspection.was_chemically_treated,
                container_test_result: inspection.container_test_result
              }
            end
          end

        end
      end
    end
  end
end
