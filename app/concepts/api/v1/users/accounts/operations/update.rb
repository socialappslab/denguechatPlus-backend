# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class Update < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :retrieve_user
            step :update_user
            tee :add_includes

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
              @input = input[:params]
            end
            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::Update.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def retrieve_user
              @ctx[:model] = UserAccount.find_by(id: @ctx['contract.default']['id'])
              return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

              errors = ErrorFormater.new_error(field: :base, msg: I18n.t('errors.users.not_found'), custom_predicate: :not_found? )
              Failure({ ctx: @ctx, type: :invalid, errors: errors }) if @ctx[:model].nil?
            end

            def update_user
              attrs = @ctx['contract.default'].values.data
              if @input['password']
                attrs['password'] = @input[:password]
              end
              unless @ctx[:model].update(attrs)
                return Failure({ ctx: @ctx, type: :invalid })
              end

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
