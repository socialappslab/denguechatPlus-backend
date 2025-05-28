# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class ChangeHouseBlock < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :change_user_house_block

            def params(input)
              @ctx = {}
              @params = input.fetch(:params)
              @current_user = input[:current_user]
              @params[:team_id] = @current_user&.teams&.first&.id
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::ChangeHouseBlock.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def change_user_house_block
              @ctx[:model] = @current_user.user_profile
              attrs = @ctx['contract.default'].values.data
              attrs[:house_block_ids] = attrs.delete(:house_block_id)

              return Success({ ctx: @ctx, type: :success }) if @ctx[:model].update(@ctx['contract.default'].values.data)

              Failure({ ctx: @ctx, type: :invalid })
            end
          end
        end
      end
    end
  end
end
