# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Queries
        class ListToVisit
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(user_account, filter)
            @model = House.includes(:state, :city, :neighborhood, :wedge, :house_blocks, :special_place, :house_statuses)
            @user_account = user_account
            @filter = filter
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:houses_by_user))
                  .yield_self(&method(:reference_code_clause))
                  .order(:reference_code)
          end

          private

          attr_reader :houses, :filter

          def houses_by_user(relation)
            return relation if @user_account.nil?

            house_block_ids = @user_account.house_blocks.pluck(:id)
            return relation if house_block_ids.nil?

            neighborhood_id = @user_account.teams&.first&.neighborhood_id
            return relation if neighborhood_id.nil?

            wedge_id = @user_account.teams&.first&.wedge_id
            return relation if wedge_id.nil?

            relation
              .joins(:house_block_houses)
              .where(house_block_houses: { house_block_id: house_block_ids })
              .where(neighborhood_id: neighborhood_id, wedge_id: wedge_id)
          end

          def reference_code_clause(relation)
            return relation if @filter.nil? || @filter[:reference_code].blank?

            relation.where('reference_code ilike :query', query: "%#{@filter[:reference_code]}%")
          end
        end
      end
    end
  end
end
