# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :check_organization
          step :check_user_accounts
          step :create_team
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Teams::Contracts::Create.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def check_organization
            return Success({ ctx: @ctx, type: :success }) if Organization.exists?(id: @params[:organization_id])

            add_errors(@ctx['contract.default'].errors,:organization_id, I18n.t('errors.users.not_found'),
                       custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, model: true })
          end

          def check_user_accounts
            return Success({ ctx: @ctx,
type: :success }) if @params[:team_members_attributes].nil? || @params[:team_members_attributes].empty?

            ids = @params[:team_members_attributes].pluck('user_account_id')
            valid = UserAccount.where(id: ids).count == ids.count
            return Success({ ctx: @ctx, type: :success }) if valid

            add_errors(@ctx['contract.default'].errors,:organization_id, I18n.t('errors.users.not_found'),
                       custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, model: true })
          end

          def create_team
            @ctx[:model] = Team.create(@ctx['contract.default'].values.data)
            return Success({ ctx: @ctx, type: :created }) if @ctx[:model].persisted?

            Failure({ ctx: @ctx, type: :invalid, model: true })
          end

          def includes
            @ctx[:include] = ['team_members']
          end
        end
      end
    end
  end
end
