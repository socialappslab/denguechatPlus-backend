# frozen_string_literal: true

module Api
  module V1
    module Comments
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(post_id, sort)
            @model = Comment
            @post_id = post_id
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:post_clause))
          end

          private

          attr_reader :comments, :post_id, :sort

          def post_clause(relation)
            return relation if @post_id.nil?

            relation.where(post_id: @post_id)
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            sort_by_table_columns(relation) if @sort[:field]
          end
        end
      end
    end
  end
end
