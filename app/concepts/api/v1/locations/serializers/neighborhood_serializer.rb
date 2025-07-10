# frozen_string_literal: true

module Api
  module V1
    module Locations
      module Serializers
        class NeighborhoodSerializer
          include Alba::Resource
          transform_keys :lower_camel

          attributes :id, :name
        end
      end
    end
  end
end
