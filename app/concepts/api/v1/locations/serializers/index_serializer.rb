# frozen_string_literal: true

module Api
  module V1
    module Locations
      module Serializers
        class IndexSerializer
          include Alba::Resource
          transform_keys :lower_camel

          attributes :name

          many :states, resource: StateSerializer
        end
      end
    end
  end
end
