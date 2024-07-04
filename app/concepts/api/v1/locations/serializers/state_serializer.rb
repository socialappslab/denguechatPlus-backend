
# frozen_string_literal: true

module Api
  module V1
    module Locations
      module Serializers

        class StateSerializer
          include Alba::Resource
          transform_keys :lower_camel

          attributes :id, :name

          many :cities, resource: CitySerializer
        end

      end
    end
  end
end
