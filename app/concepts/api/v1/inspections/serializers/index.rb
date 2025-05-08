# frozen_string_literal: true

module Api
  module V1
    module Inspections
      module Serializers
        class Index < ApplicationSerializer
          set_type :inspection

          attributes :id

          get_image_obj = ->(record) do
            return '' unless record&.photo&.attached?

            {
              id: record.photo.id,
              url: Rails.application.routes.url_helpers.url_for(record.photo)
            }
          end

          attribute :breading_site_type do |container|
            next unless container.breeding_site_type

            container.breeding_site_type.name
          end

          attribute :elimination_method_type do |container|
            next unless container.elimination_method_type

            container.elimination_method_type.name_es
          end

          attribute :elimination_method_type_other, &:other_elimination_method

          attribute :type_contents do |container|
            next if container.type_contents.blank?

            container.type_contents.map(&:name_es).join(', ')
          end

          attribute :status do |container, params|
            container.color ? I18n.with_locale(params[:language]) { I18n.t("visits.colors.#{container.color}") } : nil
          end

          attribute :water_source_types do |container|
            next if container.water_source_types.blank?

            container.water_source_types.map do |wst|
              {
                id: wst.id,
                name: wst&.name
              }
            end
          end

          attribute :water_source_other, &:water_source_other

          attribute :has_water, &:has_water

          attribute :location, &:location

          attribute :container_protections do |container|
            next if container.container_protections.blank?

            container.container_protections.map do |protection|
              {
                id: protection.id,
                name: protection&.name_es
              }
            end
          end

          attribute :container_protection_other, &:other_protection

          attribute :was_chemically_treated, &:was_chemically_treated

          attribute :photo_url do |container|
            get_image_obj.call(container)
          end
        end
      end
    end
  end
end
