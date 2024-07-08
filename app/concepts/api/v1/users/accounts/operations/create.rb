# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class Create < ApplicationOperation
            include Dry::Transaction

            tee :params
            tee :to_snake_case
            step :validate_schema
            step :create_profile
            step :create_account
            tee :add_includes

            def params(input)
              @ctx = {}
              @params = input.fetch(:params)
            end

            def to_snake_case
              @params = Api::V1::Lib::Serializers::NamingConvention.new(@params, :to_snake_case).res
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::Create.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def create_profile
              @ctx[:user_profile] = UserProfile.create(@ctx['contract.default'][:user_profile])
              return Failure({ ctx: @ctx, type: :invalid }) unless @ctx[:user_profile].persisted?

              Success({ ctx: @ctx, type: :success })
            end

            def create_account
              @ctx[:model] = @ctx[:user_profile].create_user_account(email: @params[:email],
                                                                     username: @params[:username],
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
