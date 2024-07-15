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
              @ctx[:model] = UserAccount.first
              Success({ ctx: @ctx, type: :success }) if inputs[:current_user].present?
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
