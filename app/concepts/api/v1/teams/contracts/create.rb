# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:name).filled(:string)
            required(:organization_id).filled(:integer)
            optional(:team_members_attributes).array(:hash) do
              optional(:user_account_id).filled(:integer)
            end
          end

          rule(:team_members_attributes).each do
            if value[:user_account_id] && !UserAccount.exists?(id: value[:user_account_id])
              key.failure('user_account does not exist')
            end
          end

        end
      end
    end
  end
end
