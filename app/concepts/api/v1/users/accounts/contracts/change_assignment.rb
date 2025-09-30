require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class ChangeAssignment < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              optional(:team_id).filled(:integer)
              optional(:house_block_id).filled(:integer)
              optional(:user_id).filled(:integer)
            end

            rule(:user_id) do
              if values[:user_id] && !UserAccount.exists?(id: values[:user_id])
                key(:user_id).failure(text: "The User with id #{values[:user_id]} not exists", predicate: :not_exists?)
              end
            end

            rule(:team_id) do
              if values[:team_id] && !Team.exists?(id: values[:team_id])
                key(:team_id).failure(text: "The Team with id #{values[:team_id]} not exists", predicate: :not_exists?)
              end
            end

            rule(:house_block_id) do
              if values[:house_block_id] && !HouseBlock.exists?(id: values[:house_block_id])
                key(:house_block_id).failure(text: "The HouseBlock with id #{values[:house_block_id]} not exists",
                                             predicate: :not_exists?)
              end
            end

            rule(:house_block_id, :team_id) do
              if values[:house_block_id] && values[:team_id]
                team = Team.find_by(id: values[:team_id])
                if team
                  available_house_blocks = HouseBlock.joins(:wedges)
                                                     .where(wedges: { id: team.wedge_id })
                                                     .distinct.pluck(:id)
                  if available_house_blocks.exclude?(values[:house_block_id])
                    key(:house_block_id).failure(text: "The house_block_id isn't available for this team",
                                                 predicate: :not_available?)
                  end
                end
              end
            end

            rule do
              unless values[:team_id] || values[:house_block_id]
                key(:base).failure(text: 'At least one of team_id or house_block_id must be provided',
                                   predicate: :missing_params?)
              end
            end
          end
        end
      end
    end
  end
end
