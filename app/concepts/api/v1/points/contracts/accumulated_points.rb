# frozen_string_literal: true

require 'ostruct'

module Api
  module V1
    module Points
      module Contracts
        class AccumulatedPoints < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            optional(:filter).maybe(:hash) do
              optional(:team_id).filled(:integer)
              optional(:user_account_id).filled(:integer)
              optional(:from_date).filled(:date)
              optional(:to_date).filled(:date)
            end
            optional(:sort).maybe(:string)
            optional(:order).maybe(:string, included_in?: %w[asc desc])
          end

          rule(:filter) do
            if value && value[:team_id] && value[:team_id].present? && !Team.exists?(id: value[:team_id])
              key(:team_id).failure(text: 'Team not found', predicate: :not_found?)
            end

            if value && value[:user_account_id] && value[:user_account_id].present? && !UserAccount.exists?(id: value[:user_account_id])
              key(:user_account_id).failure(text: 'User not found', predicate: :not_found?)
            end
          end
        end
      end
    end
  end
end
