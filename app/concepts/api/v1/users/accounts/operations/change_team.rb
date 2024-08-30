# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class ChangeTeam < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :update_user
            tee :add_includes

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
              @input = input[:params]
              @current_user = input[:current_user]
            end
            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::ChangeTeam.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def update_user
              attrs = @ctx['contract.default'].values.data
              attrs[:house_block_ids] = attrs.delete(:house_block_id)
              user_profile = @current_user.user_profile
              user_profile.update!(attrs)
              @ctx[:model] = @current_user
              Success({ ctx: @ctx, type: :success })
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
