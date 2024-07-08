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
            optional(:neighborhood_id).filled(:integer)
            optional(:team_members_attributes).array(:hash) do
              optional(:user_account_id).maybe(:integer)
            end
          end
        end
      end
    end
  end
end
