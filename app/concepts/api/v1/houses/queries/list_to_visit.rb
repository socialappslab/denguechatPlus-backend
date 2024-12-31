# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Queries
        class ListToVisit
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(user_account, filter)
            @model = House
            @user_account = user_account
            @filter = filter
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:houses_by_user))
                  .yield_self(&method(:reference_code_clause))
          end

          private

          attr_reader :houses, :filter

          def houses_by_user(relation)
            return relation if @user_account.nil?

            house_block_ids =  @user_account.house_blocks.pluck(:id)
            return relation if house_block_ids.nil?

            neighborhood_id = @user_account.teams&.first&.neighborhood_id
            return relation if neighborhood_id.nil?

            relation.where(house_block_id: house_block_ids, neighborhood_id: neighborhood_id)
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
