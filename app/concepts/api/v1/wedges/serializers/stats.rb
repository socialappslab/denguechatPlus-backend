# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Serializers
        class Stats < ApplicationSerializer
          set_type :wedge_stats

          attributes :houses_visited,
                     :positive_containers,
                     :coverage_percentage,
                     :houses_with_aedes_percentage,
                     :house_access_status,
                     :house_access_status_chart,
                     :container_positives,
                     :container_positives_chart,
                     :container_types_inspected,
                     :container_types_inspected_chart,
                     :risk_change,
                     :house_color_distribution
        end
      end
    end
  end
end
