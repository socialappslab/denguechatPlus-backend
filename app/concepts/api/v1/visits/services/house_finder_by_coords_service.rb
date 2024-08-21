# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Services
        class HouseFinderByCoordsService
          EARTH_RADIUS = 6371.0
          DISTANCE = 30

          def self.find_similar_house(latitude:, longitude:, house_block_id:)
            raise ArgumentError, 'latitude cannot be nil' if latitude.nil?
            raise ArgumentError, 'longitude cannot be nil' if longitude.nil?
            raise ArgumentError, 'house_block_id cannot be nil' if house_block_id.nil?

            House.where(house_block_id:).find_each do |house|
              distance = get_distance(latitude, longitude, house.latitude, house.longitude)
              return house if distance < DISTANCE
            end
            nil
          end

          private

          def self.get_distance(lat1, lon1, lat2, lon2)
            d_lat = (lat2 - lat1) * Math::PI / 180.0
            d_lon = (lon2 - lon1) * Math::PI / 180.0

            lat1 = lat1 * Math::PI / 180.0
            lat2 = lat2 * Math::PI / 180.0

            a = Math.sin(d_lat / 2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(d_lon / 2)**2
            c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

            EARTH_RADIUS * c * 1000
          end
        end
      end
    end
  end
end
