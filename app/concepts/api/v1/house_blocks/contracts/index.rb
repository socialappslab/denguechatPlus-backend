# frozen_string_literal: true

module Api
  module V1
    module HouseBlocks
      module Contracts
        class Index < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            optional(:filter).maybe(:hash) do
              optional(:wedge_id).maybe(:integer)
              optional(:team_id).maybe(:integer)
              optional(:user_profile_id).maybe(:integer)
            end

            optional(:page).maybe(:hash) do
              optional(:is_cursor).maybe(:bool)
            end

            optional(:sort).maybe(:string)
          end
        end
      end
    end
  end
end
