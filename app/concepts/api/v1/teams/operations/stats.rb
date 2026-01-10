# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Operations
        class Stats < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :find_team
          step :check_authorization
          step :gather_information

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @params.delete(:action)
            @params.delete(:controller)
            @current_user = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Teams::Contracts::Stats.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def find_team
            @team = Team.find_by(id: @params[:id], deleted_at: nil)
            return Success({ ctx: @ctx, type: :success }) if @team

            Failure({ ctx: @ctx, type: :not_found })
          end

          def check_authorization
            return Success({ ctx: @ctx, type: :success }) if @current_user.has_role?(:admin)
            return Success({ ctx: @ctx, type: :success }) if @current_user.teams.exists?(id: @team.id)

            errors = ErrorFormater.new_error(
              field: :base,
              msg: 'Not authorized to access stats for this team',
              custom_predicate: :unauthorized?
            )
            Failure({ ctx: @ctx, type: :unauthorized, errors: errors })
          end

          def gather_information
            attrs = @ctx['contract.default'].values.data
            @ctx[:data] = Api::V1::Teams::Queries::Stats.call(
              @team.id,
              from: attrs[:from],
              to: attrs[:to]
            )
            Success({ ctx: @ctx, type: :success })
          end
        end
      end
    end
  end
end
