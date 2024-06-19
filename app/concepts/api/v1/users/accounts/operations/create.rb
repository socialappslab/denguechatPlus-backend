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
            step :create_confirmation_token
            step :send_confirmation_instructions
            step :create_token

            def params(input)
              @ctx = {}
              @params = input.fetch(:params)
            end

            def validate_schema
              @ctx['contract.default'] = Api::V1::Users::Accounts::Contracts::Create.new(@params)
              is_valid = @ctx['contract.default'].validate(@params)
              return Success({ ctx: @ctx, type: :success }) if is_valid

              Failure({ ctx: @ctx, type: :invalid }) unless is_valid
            end

            def create_profile
              @ctx[:model] = UserProfile.create(
                country: Constants::UserProfile::DEFAULT_COUNTRY
              )
              return Failure({ ctx: @ctx, type: :invalid }) unless @ctx[:model].persisted?

              Success({ ctx: @ctx, type: :success })
            end

            def create_account
              @ctx[:user_account] = @ctx[:model].create_user_account(email: @params[:email],
                                                                     password: @params[:password],
                                                                     password_confirmation: @params[:password])
              return Failure({ ctx: @ctx, type: :invalid }) unless @ctx[:user_account].persisted?

              Success({ ctx: @ctx, type: :success })
            end

            def create_confirmation_token
              @ctx[:confirmation_token] =
                Api::V1::Lib::Services::TokenCreators::ConfirmAccount.call(@ctx[:user_account])
              Success({ ctx: @ctx, type: :success })
            end

            def send_confirmation_instructions
              RegistrationMailer.confirmation_instructions(
                email: @params[:email],
                redirect_to: Constants::Shared::CLIENT_URL,
                token: @ctx[:confirmation_token]
              ).deliver_later
              Success({ ctx: @ctx, type: :success })
            end

            def create_token
              result = Api::V1::Users::Lib::CreateTokens.call(@ctx, account: @ctx[:user_account])

              if result
                @ctx[:meta] = { jwt: result }
                Success({ ctx: @ctx, type: :created })
              else
                @ctx['contract.default'].errors.add(:base, I18n.t('errors.session.deactivated'))
                Failure({ ctx: @ctx, type: :unauthenticated })
              end
            end
          end
        end
      end
    end
  end
end
