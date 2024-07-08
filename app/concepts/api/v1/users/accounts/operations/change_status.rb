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

              add_errors(@ctx['contract.default'].errors,'', I18n.t('errors.users.not_found'),  custom_predicate: :not_found?)
              return Failure({ ctx: @ctx, type: :invalid }) if @ctx[:model].nil?

            end

            def change_user_status
              return Success({ ctx: @ctx, type: :success }) if @ctx[:model].update(@ctx['contract.default'].values.data)

              Failure({ ctx: @ctx, type: :invalid })
            end

          end
        end
      end
    end
  end
end
