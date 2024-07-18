# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class ShowCurrentUser < ApplicationOperation
            include Dry::Transaction

            step :params
            tee :include

            def params(inputs)
              @ctx = {}
              @ctx[:model] = inputs[:current_user]
              return Success({ ctx: @ctx, type: :success }) if inputs[:current_user].present?

              errors = ErrorFormater.new_error(field: :base, msg: I18n.t('errors.users.not_found'), custom_predicate: :not_found? )
              Failure({ ctx: @ctx, type: :invalid, errors: errors }) if @ctx[:model].nil?
            end

            def include
              @ctx[:include] = 'user_profile'
            end
          end
        end
      end
    end
  end
end
