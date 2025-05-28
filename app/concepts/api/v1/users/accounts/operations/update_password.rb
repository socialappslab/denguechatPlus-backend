# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class UpdatePassword < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :retrieve_user
            step :update_password


            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
              @current_user = input[:current_user]
            end

            def validate_schema
              @params[:current_user] = @current_user
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::UpdatePassword.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end


            def retrieve_user
              return Success({ ctx: @current_user, type: :success }) if @current_user

              Failure({ ctx: @ctx, type: :invalid,
                        errors: ErrorFormater.new_error(field: :base, msg: 'User not found', custom_predicate: :not_found?) })

            end


            def update_password
              @current_user.password = @params[:new_password].downcase
              if @current_user.save
                @ctx[:data] = @current_user
                return Success({ ctx: @ctx, type: :success })
              end
              Failure({ ctx: @ctx, type: :invalid,
                        errors: ErrorFormater.new_error(field: :base,
                                                        msg: 'Error updating passwords',
                                                        custom_predicate: :unexpected_key) })
            end
          end
        end
      end
    end
  end
end
