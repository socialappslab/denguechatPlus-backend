# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Serializers
        class HouseStatus
          include Alba::Resource
          transform_keys :lower_camel


          attributes :house_quantity, :visit_quantity, :green_quantity, :orange_quantity,
                     :red_quantity, :site_variation_percentage, :visit_variation_percentage
        end
      end
    end
  end
end
