# frozen_string_literal: true

require 'ostruct'

module Api
  module V1
    module HouseBlocks
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:name).filled(:string)
            required(:wedge_id).filled(:integer)
            required(:house_ids).array(:integer)
          end

          rule(:house_ids) do
            assigned_houses = House.where(id: value, assignment_status: :assigned)
            if assigned_houses.exists?
              key.failure(text: "the house/s #{assigned_houses.pluck(:id)} are already assigned",
                          predicate: :house_already_assigned)
            end

            existing_house_ids = House.where(id: value).pluck(:id)
            missing_house_ids = value - existing_house_ids

            if missing_house_ids.any?
              key.failure(text: "the house/s #{missing_house_ids} were not found", predicate: :not_found?)
            end
          end

          rule(:wedge_id) do
            key.failure(text: 'wedge not found', predicate: :not_found?) unless Wedge.exists?(value)
          end
        end
      end
    end
  end
end
