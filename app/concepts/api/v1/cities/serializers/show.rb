module Api
  module V1
    module Cities
      module Serializers
        class Show < ApplicationSerializer
          set_type :city

          attributes :name

          has_many :neighborhoods, serializer: Neighborhood do |object|
            object.neighborhoods.kept
          end
        end
      end
    end
  end
end
