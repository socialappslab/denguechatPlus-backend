# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Serializers
        class HouseStatus
          include Alba::Resource
          transform_keys :lower_camel


          attributes :visit_quantity

          attribute :visit_variation_percentage do |resource|
            resource.visit_variation_percentage.to_i
          end
          attributes :house_quantity

          attribute :site_variation_percentage do |resource|
            resource.site_variation_percentage.to_i
          end

          attributes :green_quantity, :orange_quantity, :red_quantity
        end
      end
    end
  end
end
