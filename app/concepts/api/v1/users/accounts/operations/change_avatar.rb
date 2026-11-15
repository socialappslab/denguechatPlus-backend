# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          # Sets the brigadista's avatar. Sending equipped_reward_level_id (null for no skin) pins that skin;
          # leaving it out keeps the current skin choice.
          class ChangeAvatar < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :check_skin_earned
            step :update_user_profile
            tee :add_includes

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
              @current_user = input[:current_user]
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::ChangeAvatar.kall(@params)
              return Success({ ctx: @ctx, type: :success }) if @ctx['contract.default'].success?

              Failure({ ctx: @ctx, type: :invalid })
            end

            def check_skin_earned
              @attrs = @ctx['contract.default'].values.data
              skin_id = @attrs[:equipped_reward_level_id]
              return Success({ ctx: @ctx, type: :success }) if skin_id.nil?

              Api::V1::Rewards::Services::Evaluate.call(user_account: @current_user)
              earned = @current_user.user_rewards.exists?(reward_level_id: skin_id)
              return Success({ ctx: @ctx, type: :success }) if earned

              errors = ErrorFormater.new_error(field: :equipped_reward_level_id, msg: 'The skin is not earned yet',
                                               custom_predicate: :not_earned?)
              Failure({ ctx: @ctx, type: :invalid, errors: })
            end

            def update_user_profile
              attrs = { avatar_id: @attrs[:avatar_id] }
              if @attrs.key?(:equipped_reward_level_id)
                attrs[:equipped_reward_level_id] = @attrs[:equipped_reward_level_id]
                attrs[:skin_manually_chosen] = true
              end
              @current_user.user_profile.update!(attrs)
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
