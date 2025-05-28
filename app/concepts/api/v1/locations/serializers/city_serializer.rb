
# frozen_string_literal: true

module Api
  module V1
    module Locations
      module Serializers
        class CitySerializer
          include Alba::Resource
          transform_keys :lower_camel

          attributes :id, :name
          has_many :neighborhoods, resource: NeighborhoodSerializer
        end
      end
    end
  end
end
