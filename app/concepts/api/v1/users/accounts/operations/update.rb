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
            step :validate_source
            step :update_user
            tee :add_includes

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
              @input = input[:params]
              @current_user = input[:current_user]
              @source = input[:source]
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::Update.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def retrieve_user
              user_profile = UserProfile.find_by(id: @ctx['contract.default']['id'])
              @ctx[:model] = user_profile.user_account
              return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

              errors = ErrorFormater.new_error(field: :base, msg: I18n.t('errors.users.not_found'),
                                               custom_predicate: :not_found?)
              Failure({ ctx: @ctx, type: :invalid, errors: errors }) if @ctx[:model].nil?
            end

            def validate_source
              res = Success({ ctx: @ctx, type: :success })

              if @source != 'web'
                if @current_user.id == @ctx['contract.default']['id']&.to_i
                  res = Success({ ctx: @ctx, type: :success })
                else
                  errors = ErrorFormater.new_error(field: :base, msg: I18n.t('errors.users.not_found'),
                                                   custom_predicate: :not_found?)
                  res = Failure({ ctx: @ctx, type: :invalid, errors: errors })
                end
              end
              res
            end

            def update_user
              attrs = @ctx['contract.default'].values.data
              if attrs[:user_profile_attributes]
                attrs[:user_profile_attributes][:house_block_ids] =
                  attrs[:user_profile_attributes].delete(:house_block_id)
              end
              attrs.delete(:id)
              attrs['password'] = @input[:password].downcase if @input['password']
              return Failure({ ctx: @ctx, type: :invalid }) unless @ctx[:model].update(attrs)

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
