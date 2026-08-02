# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Operations
        class Destroy < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :retrieve_visit
          step :authorized_user?
          step :invalidate_visit

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Visits::Contracts::Destroy.kall(@params)
            is_valid = @ctx['contract.default'].success?
            if is_valid
              @params = @ctx['contract.default'].values.data
              return Success({ ctx: @ctx, type: :success })
            end

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def retrieve_visit
            @ctx[:model] = Visit.with_discarded.find_by(id: @params[:id])
          end

          def authorized_user?
            return Success({ ctx: @ctx, type: :success }) if authorized_admin? || authorized_team_leader?

            Failure({ ctx: @ctx, type: :invalid,
                      errors: ErrorFormater.new_error(field: :base,
                                                      msg: 'Only an authorized admin or team leader can ' \
                                                           'invalidate this visit',
                                                      custom_predicate: :without_permissions) })
          end

          def invalidate_visit
            visit = @ctx[:model]
            return Success({ ctx: @ctx, type: :destroyed, model: visit }) if visit.discarded?

            ApplicationRecord.transaction do
              visit.house.with_lock do
                Point.where(visit_id: visit.id).delete_all
                visit.discard!
                ::Services::VisitStateReconciler.call!(
                  house: visit.house,
                  affected_dates: [::Services::VisitStateReconciler.reporting_date(visit.visited_at)]
                )
              end
            end

            Success({ ctx: @ctx, type: :destroyed, model: visit })
          rescue StandardError => error
            Rails.logger.error("Visit #{visit&.id} invalidation failed: #{error.message}")
            Failure({ ctx: @ctx, type: :invalid })
          end

          private

          def authorized_admin?
            return false unless @current_user.has_role?(:admin)

            visit = @ctx[:model]
            visit.house.city_id == @current_user.city_id && visit.team.organization_id == @current_user.organization_id
          end

          def authorized_team_leader?
            return false unless @current_user.has_role?(:team_leader)

            @ctx[:model].team_id.in?(@current_user.teams_under_leadership)
          end
        end
      end
    end
  end
end
