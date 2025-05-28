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
            end

          end
        end
      end
    end
  end
end
