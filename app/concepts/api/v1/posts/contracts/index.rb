# frozen_string_literal: true
require 'ostruct'

module Api
  module V1
    module Posts
      module Contracts
        class Index < Dry::Validation::Contract

          def self.kall(...)
            new.call(...)
          end

          params do
            optional(:filter).maybe(:hash) do
              optional(:team_id).filled(:integer)
              optional(:sector_id).filled(:integer)
            end
            optional(:sort).maybe(:string)
            optional(:order).maybe(:string, included_in?: %w[asc desc])
          end

          rule(:filter) do
            if value && value[:team_id] && !value[:team_id].blank? && !Team.exists?(id: value[:team_id])
              key(:team_id).failure(text: 'Team not found', predicate: :not_found?)
            end
          end
        end
      end
    end
  end
end
