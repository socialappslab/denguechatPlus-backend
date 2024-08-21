# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Queries
        class ListToVisit
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(user_account)
            @model = House
            @user_account = user_account
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:houses_by_user))
          end

          private

          attr_reader :houses

          def houses_by_user(relation)
            return relation (relation) if @user_account.nil?

            relation.where(house_block_id: @user_account.house_blocks.pluck(:id))
          end
        end
      end
    end
  end
end
