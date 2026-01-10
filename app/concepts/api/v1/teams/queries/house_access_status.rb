# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Queries
        class HouseAccessStatus
          VISIT_PERMISSION_QUESTION_TEXT = '¿Me dieron permiso para visitar la casa?'

          def initialize(team_id, from:, to:)
            @team_id = team_id
            @from = from
            @to = to || Date.current
          end

          def self.call(...)
            new(...).call
          end

          def call
            visit_permission_options.map do |option|
              {
                option_id: option.id,
                name_es: option.name_es,
                name_en: option.name_en,
                name_pt: option.name_pt,
                count: count_for_option(option.id)
              }
            end
          end

          private

          def visit_scope
            scope = Visit.where(team_id: @team_id)
            scope = scope.where(visits: { visited_at: @from.beginning_of_day.. }) if @from
            scope.where(visits: { visited_at: ..@to.end_of_day })
          end

          def visit_permission_question
            return @visit_permission_question if defined?(@visit_permission_question)

            @visit_permission_question = Question.find_by(question_text_es: VISIT_PERMISSION_QUESTION_TEXT)
          end

          def visit_permission_options
            @visit_permission_options ||= visit_permission_question&.options&.order(:position) || []
          end

          def count_for_option(option_id)
            visit_scope.where(visit_permission_option_id: option_id).count
          end
        end
      end
    end
  end
end
