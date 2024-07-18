# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class Create < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :create_profile
            step :create_account
            tee :add_includes

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
            end
            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::Create.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def create_profile
              @ctx[:user_profile] = UserProfile.create(@ctx['contract.default'][:user_profile])
              return Success({ ctx: @ctx, type: :success }) if @ctx[:user_profile].persisted?

              errors = ErrorFormater.new_error(field: :base, msg: @ctx[:user_profile].errors.full_messages.join(' '),
                                               custom_predicate: :format? )
              Failure({ ctx: @ctx, type: :invalid, errors: errors })

            end

            def create_account
              @ctx[:model] = @ctx[:user_profile].create_user_account(username: @params[:username].downcase,
                                                                     phone: @params[:phone],
                                                                     password: @params[:password],
                                                                     password_confirmation: @params[:password])
              return Failure({ ctx: @ctx, type: :invalid }) unless @ctx[:model].persisted?

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
