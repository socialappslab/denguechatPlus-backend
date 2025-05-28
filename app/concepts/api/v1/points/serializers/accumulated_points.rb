# frozen_string_literal: true

module Api
  module V1
    module Points
      module Serializers
        class AccumulatedPoints < ApplicationSerializer
          set_type :accumulated_points

          attributes :total_points


          attribute :total_points do |object|
            next unless object.respond_to?(:total_points)

            object.total_points
          end

          attribute :name do |object|
            next if !object.respond_to?(:name) && !object.respond_to?(:full_name)

            if object.respond_to?(:full_name)
              object.full_name
            else
              object.name
            end
          end
        end
      end
    end
  end
end
