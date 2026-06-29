# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class AdminDestroy < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :retrieve_user
            step :prevent_self_delete
            step :delete_user

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
              @current_user = input[:current_user]
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::AdminDestroy.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def retrieve_user
              @ctx[:model] = UserAccount.find_by(id: @ctx['contract.default'][:id])
              return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

              errors = ErrorFormater.new_error(field: :base, msg: I18n.t('errors.users.not_found'),
                                               custom_predicate: :not_found?)
              Failure({ ctx: @ctx, type: :invalid, errors: errors })
            end

            def prevent_self_delete
              return Success({ ctx: @ctx, type: :success }) if @ctx[:model].id != @current_user.id

              Failure({ ctx: @ctx, type: :forbidden })
            end

            def delete_user
              Api::V1::Users::Lib::DiscardAccount.call(user_account: @ctx[:model])
              Success({ ctx: @ctx, type: :destroyed, model: @ctx[:model] })
            rescue StandardError
              Failure({ ctx: @ctx, type: :invalid })
            end
          end
        end
      end
    end
  end
end
