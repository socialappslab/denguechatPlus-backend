# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Serializers
        class Show < ApplicationSerializer
          set_type :visit

          attributes :id, :questionnaire_id, :visited_at, :brigadist, :team, :city, :sector, :wedge,
                     :visit_permission, :host, :answers, :notes

          translate_multilang_values = ->(collection, language = 'es', current_value = nil) {
            return '' unless current_value

            values = Array(current_value)

            values.map do |val|
              match = collection.find do |q|
                q[:name_en] == val || q[:name_es] == val || q[:name_pt] == val
              end

              if match
                match[:"name_#{language}"]
              else
                val
              end
            end
          }

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

          attribute :visitStatus do |object|
            object.status
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

          attribute :host do |visit|
            next unless visit.host

            translate_multilang_values.call(Constants::VisitConstants::HOST, visit.language, visit.host.split(', '))
          end

          attribute :modification_history do |visit|
            versions = visit.versions
            next nil unless versions
            next unless versions.last

            modify_by = JSON.parse(visit.versions.last.whodunnit)['full_name'] if visit.versions.last.whodunnit
            {
              lastModified: visit.updated_at,
              modifiedBy: modify_by
            }
          end

          attribute :family_education_topics do |visit|
            Constants::DownloadCsvConstants::QUESTION_TALK_ABOUT_TOPICS.map do |item|
              {
                name: item[:"name_#{visit.language}"],
                checked: (item.values & visit.family_education_topics).any?
              }
            end
          end

          attribute :inspections do |visit|
            next unless visit.inspections.any?

            visit.inspections.map do |inspection|
              {
                id: inspection.id,
                breedingSiteType: {
                  breeding_site_type_id: inspection.breeding_site_type_id,
                  breeding_site_type_name: inspection.breeding_site_type&.send("name_#{visit.language}"),
                },
                eliminationMethodTypes: inspection.elimination_method_types.map do |elimination_method_type|
                  {
                    id: elimination_method_type.id,
                    name: elimination_method_type.send("name_#{visit.language}")
                  }
                end,
                waterSourceType: inspection.water_source_types.map do |wst|
                  {
                    id: wst.id,
                    name: wst&.send("name_#{visit.language}")
                  }
                end,
                container_protections: inspection.container_protections.map do |protection|
                  {
                    id: protection.id,
                    name: protection&.send("name_#{visit.language}")
                  }
                end,
                other_container_protection: inspection.other_protection,
                inspection_type_contents: [
                  inspection.type_contents.map do |content|
                    {
                      id: content.id,
                      name: content.send("name_#{visit.language}")
                    }
                  end
                ],
                has_water: inspection.has_water,
                was_chemically_treated: Constants::DownloadCsvConstants::WAS_CHEMICALLY_TRANSLATIONS.map do |item|
                  {
                    name: item[:"name_#{visit.language}"],
                    checked: item.values.include?(inspection.was_chemically_treated)
                  }
                end,
              container_test_result: inspection.container_test_result
              }
            end
          end
        end
      end
    end
  end
end
