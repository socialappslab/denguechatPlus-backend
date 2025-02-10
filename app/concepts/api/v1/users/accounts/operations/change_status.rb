# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Operations
          class ChangeStatus < ApplicationOperation
            include Dry::Transaction


            tee :params
            step :validate_schema
            step :retrieve_user
            step :change_user_status
            tee :restart_login_attemps_counter
            tee :send_sms_notification

            def params(input)
              @ctx = {}
              @params = input.fetch(:params)
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::ChangeStatus.kall(@params)
              is_valid = @ctx['contract.default'].success?
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def retrieve_user
              @ctx[:model] = UserAccount.find_by(id: @ctx['contract.default']['id'])
              return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

              errors = ErrorFormater.new_error(field: :base, msg: I18n.t('errors.users.not_found'), custom_predicate: :not_found? )
              return Failure({ ctx: @ctx, type: :invalid, errors: errors }) if @ctx[:model].nil?

            end

            def change_user_status

              return Success({ ctx: @ctx, type: :success }) if @ctx[:model].update(@ctx['contract.default'].values.data)

              Failure({ ctx: @ctx, type: :invalid })
            end

            def restart_login_attemps_counter
              if  @ctx[:model].previous_changes[:status]  == ['locked', 'active']
                Api::V1::Users::Lib::LoginAttempt.call(@ctx[:model]).reset_attempts_count!
              end
            end

            def send_sms_notification
              if @ctx[:model].previous_changes[:status]  == ['pending', 'active']
                ::Users::ApprovalAccountWorker.perform_async(@ctx[:model].id)
              end
            end

          end
        end
      end
    end
  end
end
