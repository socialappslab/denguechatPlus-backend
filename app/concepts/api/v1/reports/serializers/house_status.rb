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
            res = resource.visit_variation_percentage.to_i
            res = 100 if res.zero? || res.nil?
            res
          end
          attributes :house_quantity

          attribute :site_variation_percentage do |resource|
            res = resource.site_variation_percentage.to_i
            res = 100 if res.zero? || res.nil?
            res
          end

          attributes :green_quantity, :orange_quantity, :red_quantity
        end
      end
    end
  end
end
