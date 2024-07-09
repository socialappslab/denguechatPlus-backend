# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Contracts
        class Destroy < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            required(:team_ids).filled(:array).each(:integer)
          end
        end
      end
    end
  end
end
