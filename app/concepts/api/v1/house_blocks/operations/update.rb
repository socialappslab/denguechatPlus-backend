# frozen_string_literal: true

module Api
  module V1
    module HouseBlocks
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :transform_params
          step :update_house_blocks

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @params.delete(:action)
            @params.delete(:controller)
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::HouseBlocks::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def transform_params
            @data = @ctx['contract.default'].values.data
            @house_ids = @data.delete(:house_ids)
          end

          def update_house_blocks
            ActiveRecord::Base.transaction do
              begin
                @ctx[:model] = HouseBlock.find_by(id: @data[:id])
                update_houses!(@house_ids) if @house_ids.present?
                Success({ ctx: @ctx, type: :created })
              rescue ActiveRecord::RecordInvalid => e
                errors = ErrorFormater.new_error(field: :base, msg: e.message, custom_predicate: :user_account_without_confirmation?)
                Failure({ ctx: @ctx, type: :invalid, errors: errors })
              end
            end
          end

          private

          def update_houses!(new_house_ids)
            @ctx[:model].houses
                        .where.not(id: new_house_ids)
                        .update_all(
                          house_block_id: nil,
                          assignment_status: :orphaned
                       )

            House.where(id: new_house_ids)
                 .update_all(house_block_id: @ctx[:model].id, assignment_status: :assigned)
          end
        end
      end
    end
  end
end
