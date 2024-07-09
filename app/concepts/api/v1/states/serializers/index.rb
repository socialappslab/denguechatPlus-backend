# frozen_string_literal: true

module Api
  module V1
    module States
      module Serializers
        class Index < ApplicationSerializer
          set_type :state

          attributes :name
          has_many :cities, serializer: City do |object|
            object.neighborhoods.kept
          end
        end
      end
    end
  end
end
