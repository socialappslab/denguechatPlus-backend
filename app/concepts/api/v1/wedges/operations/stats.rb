# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Operations
        class Stats < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :find_wedge
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
            @ctx['contract.default'] = Api::V1::Wedges::Contracts::Stats.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid }) unless is_valid
          end

          def find_wedge
            @wedge = Wedge.find_by(id: @params[:id], discarded_at: nil)
            return Success({ ctx: @ctx, type: :success }) if @wedge

            Failure({ ctx: @ctx, type: :not_found })
          end

          def check_authorization
            return Success({ ctx: @ctx, type: :success }) if @current_user.has_role?(:admin)

            user_wedge_ids = @current_user.house_blocks.joins(:wedges).pluck('wedges.id').uniq
            return Success({ ctx: @ctx, type: :success }) if user_wedge_ids.include?(@wedge.id)

            errors = ErrorFormater.new_error(
              field: :base,
              msg: 'Not authorized to access stats for this wedge',
              custom_predicate: :unauthorized?
            )
            Failure({ ctx: @ctx, type: :unauthorized, errors: errors })
          end

          def gather_information
            attrs = @ctx['contract.default'].values.data
            @ctx[:data] = Api::V1::Wedges::Queries::Stats.call(
              @wedge.id,
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
