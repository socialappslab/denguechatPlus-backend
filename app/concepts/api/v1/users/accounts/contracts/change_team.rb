require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class ChangeTeam < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              required(:team_id).filled(:integer)
              required(:house_block_id).filled(:integer)
              optional(:user_id).filled(:integer)
            end

            rule(:team_id) do
              if values[:team_id] && !Team.kept.exists?(id: values[:team_id])
                key(:team_id).failure(text: "The brigade with id #{values[:team_id]} not exists", predicate: :not_exists?)
              end
            end

            rule(:user_id) do
              if values[:user_id] && !UserAccount.exists?(id: values[:user_id])
                key(:user_id).failure(text: "The User with id #{values[:user_id]} not exists", predicate: :not_exists?)
              end
            end

            rule(:house_block_id) do
              if values[:house_block_id] && !HouseBlock.exists?(id: values[:house_block_id])
                key(:team_id).failure(text: "The HouseBlock with id #{values[:house_block_id]} not exists",
                                      predicate: :not_exists?)
              end

              if values[:team_id] && values[:house_block_id] && HouseBlock.find_by(id: values[:house_block_id])&.team_id != values[:team_id]
                key(:house_team_id).failure(
                  text: "The HouseBlock with id #{values[:house_block_id]} is not belongs to the new team", predicate: :is_new?)
              end
            end

          end
        end
      end
    end
  end
end
