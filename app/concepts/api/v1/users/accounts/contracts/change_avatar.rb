# frozen_string_literal: true

require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class ChangeAvatar < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              required(:avatar_id).filled(:integer)
              optional(:equipped_reward_level_id).maybe(:integer)
            end

            rule(:avatar_id) do
              next if Avatar.catalog.exists?(id: value)

              key.failure(text: 'The avatar not exists', predicate: :not_exists?)
            end
          end
        end
      end
    end
  end
end
