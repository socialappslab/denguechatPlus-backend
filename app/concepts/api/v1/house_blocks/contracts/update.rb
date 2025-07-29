# frozen_string_literal: true

require 'ostruct'

module Api
  module V1
    module HouseBlocks
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            optional(:name).filled(:string)
            optional(:wedge_id).filled(:integer)
            optional(:house_ids).array(:integer)
          end

          rule(:house_ids) do
            next unless value

            block_id = values[:id]
            next unless block_id

            block_type = HouseBlock.find_by(id: block_id)&.block_type

            assigned_house_ids = HouseBlockHouse
                                   .joins(:house)
                                   .joins(:house_block)
                                   .where.not(house_block_id: block_id, house_id: value)
                                   .where(house_id: value)
                                   .where(house_blocks: {block_type: block_type})
                                   .merge(House.where(assignment_status: :assigned))
                                   .pluck(:house_id)

            if assigned_house_ids.any?
              key.failure(
                text: "the house/s #{assigned_house_ids} are already assigned",
                predicate: :house_already_assigned
              )
            end

            existing_house_ids = House.where(id: value).pluck(:id)
            missing_house_ids = value - existing_house_ids

            if missing_house_ids.any?
              key.failure(
                text: "the house/s #{missing_house_ids} were not found",
                predicate: :not_found?
              )
            end
          end

          rule(:wedge_id) do
            next unless value

            key.failure(text: 'wedge not found', predicate: :not_found?) unless Wedge.exists?(value)
          end
        end
      end
    end
  end
end
