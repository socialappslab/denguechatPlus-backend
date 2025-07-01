# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Serializers
        class Show < ApplicationSerializer # rubocop:disable Metrics/ClassLength
          set_type :inspection

          build_breading_site_type = ->(container) {
            BreedingSiteType.all.map do |bst|
              {
                id: bst.id,
                name: bst.name,
                value: bst.id,
                selected: bst.id == container.breeding_site_type_id
              }
            end
          }

          build_elimination_method_types = ->(container) {
            EliminationMethodType.all.map do |elimination_method_type|
              res = {
                id: elimination_method_type.id,
                name: elimination_method_type.name_es,
                value: elimination_method_type.id,
                selected: elimination_method_type.id.in?(container.elimination_method_type_ids)
              }

              if elimination_method_type.name_es.downcase.in?(%w[otro other outro])
                res[:is_text_area] = true
                res[:other_resource_name] = 'eliminationMethodTypeOther'
              end
              res
            end
          }

          build_type_contents = ->(container) {
            TypeContent.all.map do |bst|
              {
                id: bst.id,
                name: bst.name_es,
                value: bst.id,
                selected: bst.id.in?(container.type_contents.pluck(:id)),
                is_text_area: bst.name_es.downcase.in?(%w[otro other outro])
              }
            end
          }

          build_water_source_types = ->(container) {
            WaterSourceType.all.map do |wst|
              res = {
                id: wst.id,
                name: wst.name,
                value: wst.id,
                selected: wst.id.in?(container.water_source_type_ids)
              }
              if wst.name.downcase.in?(%w[otro other outro])
                res[:is_text_area] = true
                res[:other_resource_name] = 'waterSourceOther'
              end
              res
            end
          }

          build_container_protection = ->(container) {
            container_protections = container.container_protection_ids
            ContainerProtection.all.map do |bst|
              res = {
                id: bst.id,
                name: bst.name_es,
                value: bst.id,
                selected: bst.id.in?(container_protections)
              }
              if bst.name_es.downcase.in?(%w[otro other outro])
                res[:is_text_area] = true
                res[:other_resource_name] = 'containerProtectionOther'
              end
              res
            end
          }

          build_was_chemically_treated = ->(container) {
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

          get_image_obj = ->(record) do
            return '' unless record&.photo&.attached?

            {
              id: record.photo.id,
              url: Rails.application.routes.url_helpers.url_for(record.photo)
            }
          end

          attribute :breading_site_type do |container|
            build_breading_site_type.call(container)
          end

          attribute :elimination_method_types do |container|
            build_elimination_method_types.call(container)
          end

          attribute :elimination_method_type_other, &:other_elimination_method

          attribute :type_contents do |container|
            build_type_contents.call(container)
          end

          attribute :status do |container|
            container.status_i18n(container.color)
          end

          attribute :water_source_types do |container|
            build_water_source_types.call(container)
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
