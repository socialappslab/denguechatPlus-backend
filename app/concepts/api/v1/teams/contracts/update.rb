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
            optional(:user_profile_ids).filled(:array).each(:integer)
          end

          rule(:user_profile_ids).each do
            if values[:user_profile_ids] && !UserProfile.exists?(id: values[:user_profile_ids])
              key(:user_profile_ids).failure(text: 'user_profile does not exist', predicate: :filled?)
            end
          end

        end
      end
    end
  end
end
