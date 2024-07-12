# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            optional(:name).filled(:string)
            optional(:organization_id).filled(:string)
            optional(:team_members_attributes).array(:hash) do
              optional(:user_account_id).filled(:integer)
              optional(:_destroy).filled(:integer)
            end
          end

          rule(:team_members_attributes).each do
            if value[:user_account_id] && TeamMember.exists?(team_id: values[:id], user_account_id: value[:user_account_id])
              key(:user_account_id).failure('member already exists in this team')
            end
          end

        end
      end
    end
  end
end
