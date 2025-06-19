require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class ChangeHouseBlock < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              required(:house_block_id).filled(:integer)
              required(:team_id).filled(:integer)
            end

            rule(:house_block_id) do
              unless values[:team_id]
                key(:house_block_id).failure(text: "The house_block_id isn't correct", predicate: :not_exists?)
              end
              team = Team.find_by(id: values[:team_id])
              unless team
                key(:house_block_id).failure(text: "The house_block_id isn't correct", predicate: :not_exists?)
              end
              available_house_blocks = HouseBlock.joins(:wedges)
                        .where(wedges: { id: team&.wedge_id })
                        .distinct.pluck(:id)
              if values[:house_block_id] && available_house_blocks.exclude?(values[:house_block_id])
                key(:house_block_id).failure(text: "The house_block_id isn't correct", predicate: :not_exists?)
              end
            end

          end
        end
      end
    end
  end
end
