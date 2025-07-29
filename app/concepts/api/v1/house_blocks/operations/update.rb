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
                @ctx[:model].update!(@ctx['contract.default'].values.data)
                Success({ ctx: @ctx, type: :created })
              rescue ActiveRecord::RecordInvalid => error
                errors = ErrorFormater.new_error(field: :base, msg: error.message,
                                                 custom_predicate: :user_account_without_confirmation?)
                Failure({ ctx: @ctx, type: :invalid, errors: errors })
              end
            end
          end

          private

          def update_houses!(new_house_ids)
            @ctx[:model].house_block_houses
                        .where.not(house_id: new_house_ids)
                        .destroy_all

            House.left_outer_joins(:house_block_houses)
                 .where(id: @ctx[:model].houses.pluck(:id) - new_house_ids)
                 .where(house_block_houses: { id: nil }) # sin asignaciones
                 .update_all(assignment_status: :orphaned)

            new_house_ids.each do |house_id|
              HouseBlockHouse.find_or_create_by!(
                house_id: house_id,
                house_block_id: @ctx[:model].id
              )
            end

            House.where(id: new_house_ids).update_all(assignment_status: :assigned)
          end
        end
      end
    end
  end
end
