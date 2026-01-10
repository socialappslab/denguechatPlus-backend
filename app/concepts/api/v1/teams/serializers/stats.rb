# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Serializers
        class Stats < ApplicationSerializer
          set_type :team_stats

          attributes :houses_visited,
                     :positive_containers,
                     :coverage_percentage,
                     :houses_with_aedes_percentage,
                     :house_access_status,
                     :container_positives,
                     :risk_change,
                     :house_color_distribution
        end
      end
    end
  end
end
