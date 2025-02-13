# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Serializers
        class Show < ApplicationSerializer
          set_type :inspection


          build_breading_site_type = lambda { |container|
            BreedingSiteType.all.map do |bst|
              {
                id: bst.id,
                name: bst.name,
                value: bst.id,
                selected: bst.id == container.breeding_site_type_id
              }
            end
          }

          build_elimination_method_type = lambda { |container|
            EliminationMethodType.all.map do |bst|
              res = {
                id: bst.id,
                name: bst.name_es,
                value: bst.id,
                selected: bst.id == container.elimination_method_type_id
              }

              if bst.name_es.downcase.in?(['otro', 'other', 'outro'])
                res[:is_text_area] = true
                res[:other_resource_name]= 'eliminationMethodTypeOther'
              end
              res
            end
          }

          build_type_contents = lambda { |container|
            TypeContent.all.map do |bst|
              {
                id: bst.id,
                name: bst.name_es,
                value: bst.id,
                selected: bst.id.in?(container.type_contents.pluck(:id)),
                is_text_area: bst.name_es.downcase.in?(['otro', 'other', 'outro'])
              }
            end
          }

          build_water_source_type = lambda { |container|
            WaterSourceType.all.map do |bst|
              res = {
                id: bst.id,
                name: bst.name,
                value: bst.id,
                selected: bst.id == container.water_source_type_id
              }
              if bst.name.downcase.in?(['otro', 'other', 'outro'])
                res[:is_text_area] = true
                res[:other_resource_name]= 'waterSourceOther'
              end
              res
            end
          }

          build_container_protection = lambda { |container|
            container_protections = container.container_protection_ids
            ContainerProtection.all.map do |bst|
              res = {
                id: bst.id,
                name: bst.name_es,
                value: bst.id,
                selected: bst.id.in?(container_protections)
              }
              if bst.name_es.downcase.in?(['otro', 'other', 'outro'])
                res[:is_text_area] = true
                res[:other_resource_name]= 'containerProtectionOther'
              end
              res
            end
          }

          build_was_chemically_treated = lambda { |container|
            [
              {
                name: 'Sí, fue tratado (revise el registro detrás de la puerta)',
                value: 'Sí, fue tratado (revise el registro detrás de la puerta)',
                selected: container.was_chemically_treated == 'Sí, fue tratado (revise el registro detrás de la puerta)'
              },
              {
                name: 'No, no fue tratado',
                value: 'No, no fue tratado',
                selected: container.was_chemically_treated == 'No, no fue tratado'
              },
              {
                name: 'No lo sé',
                value: 'No lo sé',
                selected: container.was_chemically_treated == 'No lo sé'
              }
            ]
          }

          get_image_obj = lambda do |record|
            return '' unless record&.photo&.attached?

            {
              id: record.photo.id,
              url: Rails.application.routes.url_helpers.url_for(record.photo)
            }
          end

          attribute :breading_site_type do |container|
            build_breading_site_type.call(container)
          end

          attribute :elimination_method_type do |container|
            build_elimination_method_type.call(container)
          end

          attribute :elimination_method_type_other, &:other_elimination_method

          attribute :type_contents do |container|
            build_type_contents.call(container)
          end

          attribute :status do |container|
            container.status_i18n(container.color)
          end

          attribute :water_source_type do |container|
            build_water_source_type.call(container)

          end

          attribute :water_source_other, &:water_source_other

          attribute :has_water, &:has_water

          attribute :location, &:location

          attribute :container_protections do |container|
            build_container_protection.call(container)
          end

          attribute :container_protection_other, &:other_protection

          attribute :was_chemically_treated do |container|
            build_was_chemically_treated.call(container)
          end

          attribute :photo_url do |container|
            get_image_obj.call(container)
          end
        end
      end
    end
  end
end
