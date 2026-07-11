# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :update_house

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params]).symbolize_keys
            @params.delete(:action)
            @params.delete(:controller)
            @current_user = input[:current_user]
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Houses::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?

            if is_valid
              @params = @ctx['contract.default'].values.data
              return Success({ ctx: @ctx, type: :success })
            end

            Failure({ ctx: @ctx, type: :invalid })
          end

          def update_house
            begin
              house = House.find_by(id: @params[:id])
              return Failure({ ctx: @ctx, type: :not_found }) unless house

              house_block_id = @params.delete(:house_block_id)
              house.update!(@params)
              update_house_block!(house, house_block_id) if house_block_id
              @ctx[:model] = house
              Success({ ctx: @ctx, type: :updated })
            rescue StandardError => error
              errors = ErrorFormater.new_error(field: :base, msg: error, custom_predicate: :unexpected_key)
              Failure({ ctx: @ctx, type: :invalid, errors: errors })
            end
          end

          private

          def update_house_block!(house, house_block_id)
            house_block = HouseBlock.find_by(id: house_block_id)
            return unless house_block

            if house_block.block_type.present?
              house.house_block_houses
                   .joins(:house_block)
                   .where(house_blocks: { block_type: house_block.block_type })
                   .where.not(house_block_id: house_block.id)
                   .destroy_all
            end

            HouseBlockHouse.find_or_create_by!(house:, house_block:)
            house.update!(assignment_status: :assigned)
          end
        end
      end
    end
  end
end
