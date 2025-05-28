# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Serializers
        class Show < ApplicationSerializer
          set_type :house

          attributes :id, :reference_code, :assignment_status,
                     :last_sync_time, :last_visit,
                     :address, :latitude, :longitude,
                     :source, :status, :tariki_status, :created_at,
                     :updated_at, :external_id, :notes

          attribute :country do |house|
            { id: house.country.id, name: house.country.name } if house.country
          end

          attribute :state do |house|
            { id: house.state.id, name: house.state.name } if house.state
          end

          attribute :city do |house|
            { id: house.city.id, name: house.city.name } if house.city
          end

          attribute :neighborhood do |house|
            { id: house.neighborhood.id, name: house.neighborhood.name } if house.neighborhood
          end

          attribute :wedge do |house|
            { id: house.wedge.id, name: house.wedge.name } if house.wedge
          end

          attribute :house_block do |house|
            { id: house.house_block.id, name: house.house_block.name } if house.house_block
          end

          attribute :special_place do |house|
            { id: house.special_place.id, name: house.special_place.name } if house.special_place
          end

        end
      end
    end
  end
end
