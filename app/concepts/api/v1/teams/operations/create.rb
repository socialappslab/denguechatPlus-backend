# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Operations
        class Create < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :change_sector_for_neighborhood
          step :create_team
          tee :assign_house_blocks_to_members
          # tee :includes

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

          def change_sector_for_neighborhood
            @data = @ctx['contract.default'].values.data
            @data[:neighborhood_id] = @data.delete(:sector_id)
          end

          def create_team
            @ctx[:model] = Team.create(@data)
            return Success({ ctx: @ctx, type: :created }) if @ctx[:model].persisted?

            Failure({ ctx: @ctx, type: :invalid, model: true })
          end

          def assign_house_blocks_to_members
            team = @ctx[:model]
            Api::V1::Teams::Services::HouseBlockAssigner.assign(team:, member_ids: team.member_ids)
          end

          def includes
            @ctx[:include] = %w[user_profiles organization]
          end
        end
      end
    end
  end
end
