# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Serializers
        class ListToVisit < ApplicationSerializer
          set_type :house

          attributes :id, :reference_code, :house_type, :address, :latitude, :longitude, :notes, :status, :container_count, :created_at, :updated_at


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
              name: house.special_place.name
            }
          end

          attribute :last_visit do |house|
            last_visit = Visit.where(house_id: house.id).last
            next unless last_visit

            last_visit.created_at.to_time.to_i * 1000
          end
        end
      end
    end
  end
end
