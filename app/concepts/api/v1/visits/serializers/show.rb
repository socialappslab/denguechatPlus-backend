# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Serializers
        class Show < ApplicationSerializer
          set_type :visit

          attributes :id, :house_id, :user_account_id, :team_id,
                     :visit_permission, :notes, :host, :questionnaire_id,
                     :answers, :created_at

          attribute :inspections do |visit|
            next unless visit.inspections.any?

            visit.inspections.map do |inspection|
              {
                id: inspection.id,
                breeding_site_type_id: inspection.breeding_site_type_id,
                elimination_method_type_id: inspection.elimination_method_type_id,
                water_source_type_id: inspection.water_source_type_id,
                has_water: inspection.has_water,
                was_chemically_treated: inspection.was_chemically_treated,
                container_test_result: inspection.container_test_result,
                tracking_type_required: inspection.container_test_result,
                created_at: inspection.created_at
              }
            end
          end

        end
      end
    end
  end
end
