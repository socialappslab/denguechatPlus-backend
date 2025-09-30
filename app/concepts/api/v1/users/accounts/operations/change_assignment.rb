# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class ChangeAssignment < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :check_authorization
            step :update_user_assignment
            tee :add_includes

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
              @input = input[:params]
              @current_user = input[:current_user]
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::ChangeAssignment.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def check_authorization
              attrs = @ctx['contract.default'].values.data
              target_user_id = attrs[:user_id]

              if target_user_id.nil?
                @target_user = @current_user
                return Success({ ctx: @ctx, type: :success })
              end

              if @current_user.has_role?(:facilitador) || @current_user.has_role?(:admin)
                @target_user = UserAccount.find_by(id: target_user_id)
                return Success({ ctx: @ctx, type: :success }) if @target_user

                errors = ErrorFormater.new_error(
                  field: :user_id,
                  msg: 'Target user not found',
                  custom_predicate: :not_found?
                )
                Failure({ ctx: @ctx, type: :not_found, errors: errors })
              else
                errors = ErrorFormater.new_error(
                  field: :base,
                  msg: 'Not authorized to change other users assignments',
                  custom_predicate: :unauthorized?
                )
                Failure({ ctx: @ctx, type: :unauthorized, errors: errors })
              end
            end

            def update_user_assignment
              attrs = @ctx['contract.default'].values.data

              update_attrs = {}
              # Team assignment (belongs_to relationship - singular)
              update_attrs[:team_id] = attrs[:team_id] if attrs[:team_id]
              # House block assignment (has_many relationship - plural)
              update_attrs[:house_block_ids] = [attrs[:house_block_id]] if attrs[:house_block_id]

              user_profile = @target_user.user_profile
              if user_profile.update(update_attrs)
                @ctx[:model] = @target_user
                Success({ ctx: @ctx, type: :success })
              else
                errors = ErrorFormater.new_error(
                  field: :base,
                  msg: 'Failed to update user assignment',
                  custom_predicate: :invalid?
                )
                Failure({ ctx: @ctx, type: :invalid, errors: errors })
              end
            end

            def add_includes
              @ctx[:include] = 'user_profile'
            end
          end
        end
      end
    end
  end
end
