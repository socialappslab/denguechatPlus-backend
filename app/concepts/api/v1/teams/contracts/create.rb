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
            optional(:user_profile_ids).filled(:array).each(:integer)
          end

          rule(:user_profile_ids).each do
            if values[:user_profile_ids] && !UserProfile.exists?(id: values[:user_profile_ids])
              key(:user_profile_ids).failure(text: 'user_profile does not exist', predicate: :not_found?)
            end
          end

          rule(:name) do
            if values[:name] && Team.exists?(name: values[:name].downcase)
              key(:name).failure(text: 'the team name is already in use', predicate: :unique?)
            end
          end

        end
      end
    end
  end
end
