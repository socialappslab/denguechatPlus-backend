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

          attribute :breading_site_type do |container, params|
            next unless container.breeding_site_type

            container.breeding_site_type.send(:"name_#{params[:language]}")
          end

          attribute :elimination_method_types do |container, params|
            next if container.elimination_method_types.blank?

            container.elimination_method_types.map do |elimination_method_type|
              {
                id: elimination_method_type.id,
                name: elimination_method_type.send(:"name_#{params[:language]}")
              }
            end
          end

          attribute :elimination_method_type_other, &:other_elimination_method

          attribute :type_contents do |container, params|
            next if container.type_contents.blank?

            container.type_contents.map(&:"name_#{params[:language]}").join(', ')
          end

          attribute :status do |container, params|
            container.color ? I18n.with_locale(params[:language]) { I18n.t("visits.colors.#{container.color}") } : nil
          end

          attribute :water_source_types do |container, params|
            next if container.water_source_types.blank?

            container.water_source_types.map do |wst|
              {
                id: wst.id,
                name: wst&.send(:"name_#{params[:language]}")
              }
            end
          end

          attribute :water_source_other, &:water_source_other

          attribute :has_water do |container, params|
            Constants::DownloadCsvConstants::BOOLEAN_TRANSLATIONS[params[:language]][container.has_water]
          end

          attribute :location, &:location

          attribute :container_protections do |container, params|
            next if container.container_protections.blank?

            container.container_protections.map do |protection|
              {
                id: protection.id,
                name: protection&.send(:"name_#{params[:language]}")
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
