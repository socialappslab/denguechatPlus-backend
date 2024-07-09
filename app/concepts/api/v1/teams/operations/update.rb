# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :model
          step :update_organization
          tee :includes

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Teams::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def model
            @ctx[:model] = Team.kept.find_by(id: @params[:id])
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            add_errors(@ctx['contract.default'].errors,nil, I18n.t('errors.users.not_found'),
                       custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, model: true }) unless @ctx[:model]
          end

          def update_members
            user_account_ids = @ctx['contract.default'].values.data[:team_members_attributes].pluck(:_destroy)
            team_id = @ctx['contract.default'].values.data[:id]
            TeamMember.where(team_id: team_id, user_account_id: user_account_ids).destroy_all
          end

          def update_organization
            ActiveRecord::Base.transaction do
              begin
                @ctx[:model].update!(@ctx['contract.default'].values.data)
                update_members
                return Success({ ctx: @ctx, type: :success })
              rescue ActiveRecord::RecordInvalid => invalid
                add_errors(@ctx['contract.default'].errors,nil, I18n.t('errors.users.not_found'),
                           custom_predicate: :not_found?)
                Failure({ ctx: @ctx, type: :invalid, model: true })
                raise ActiveRecord::Rollback
              end
            end
          end

          def includes
            @ctx[:include] = ['team_members']
          end

        end
      end
    end
  end
end
