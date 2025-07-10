# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Serializers
        class Index < ApplicationSerializer
          set_type :house

          attributes :id, :discarded_at, :reference_code, :house_type, :address,
                     :latitude, :longitude, :notes, :status, :container_count,
                     :assignment_status, :created_at, :updated_at

          attribute :country do |house|
            next unless house.country

            {
              id: house.country.id,
              name: house.country.name
            }
          end

          attribute :state do |house|
            next unless house.state

            {
              id: house.state.id,
              name: house.state.name
            }
          end

          attribute :city do |house|
            next unless house.city

            {
              id: house.city.id,
              name: house.city.name
            }
          end

          attribute :neighborhood do |house|
            next unless house.neighborhood

            {
              id: house.neighborhood.id,
              name: house.neighborhood.name
            }
          end

          attribute :wedge do |house|
            next unless house.wedge

            {
              id: house.wedge.id,
              name: house.wedge.name
            }
          end

          attribute :house_block do |house|
            next unless house.house_block

            {
              id: house.house_block.id,
              name: house.house_block.name
            }
          end

          attribute :special_place do |house|
            next unless house.special_place

            {
              id: house.special_place.id,
              name: house.special_place.name_es,
              name_en: house.special_place.name_en,
              name_pt: house.special_place.name_pt
            }
          end

          attribute :created_by do |house|
            next unless house.created_by

            {
              id: house.created_by.id,
              name: house.created_by.first_name,
              last_name: house.created_by.last_name
            }
          end
        end
      end
    end
  end
end
