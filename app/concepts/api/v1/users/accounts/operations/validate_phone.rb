# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class ValidatePhone < ApplicationOperation
            include Dry::Transaction

            tee :params
            step :validate_schema
            step :retrieve_user
            step :check_last_code_recovery_sent
            tee :generate_code
            tee :send_sms

            def params(input)
              @ctx = {}
              @params = to_snake_case(input[:params])
            end
            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::ValidatePhone.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def retrieve_user
              @user_account = UserAccount.find_by(username: @params[:username], phone: @params[:phone])
              return Success({ ctx: @user_account, type: :success }) if @user_account

              Failure({ ctx: @ctx, type: :invalid })
            end

            def check_last_code_recovery_sent
              return Success({ ctx: @user_account, type: :success }) if @user_account.last_recovery_code_sent_at.nil?
              return Success({ ctx: @user_account, type: :success }) if (DateTime.now - 1.minute) > @user_account.last_recovery_code_sent_at

              Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'You can only request a password recovery code once per minute. Please try again later.', custom_predicate: :code_recovery_in_a_short_time )})

            end

            def generate_code
              @recovery_code = @user_account.user_code_recoveries.create(code: SecureRandom.hex(3))
            end

            def send_sms
              begin
                ::Twillio::UserMessage.send_recovery_code(@user_account.phone, @recovery_code.code)
                 return Success({ ctx: @user_account, type: :success })
              rescue => error
                return Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: "There was a problem sending the message to the number #{@user_account.phone}", custom_predicate: :format? )})
              end
            end
          end
        end
      end
    end
  end
end
