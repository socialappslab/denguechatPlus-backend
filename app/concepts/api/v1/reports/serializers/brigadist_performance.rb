# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Serializers
        class BrigadistPerformance
          include Alba::Resource
          transform_keys :lower_camel


           attributes :visit_rank, :green_house_rank

          attribute :visit_rank do |resource|
            resource.visit_rank.map do |visit_rank|
              {
                first_name: visit_rank.first_name,
                last_name: visit_rank.last_name,
                quantity: visit_rank.quantity
              }
            end
          end

          attribute :green_house_rank do |resource|
            resource.green_house_rank.map do |green_house_rank|
              {
                first_name: green_house_rank.first_name,
                last_name: green_house_rank.last_name,
                quantity: green_house_rank.quantity
              }
            end
          end

        end
      end
    end
  end
end
