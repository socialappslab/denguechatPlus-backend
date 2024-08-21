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
            return relation (relation) if @user_account.nil?

            relation.where(house_block_id: @user_account.house_blocks.pluck(:id))
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
