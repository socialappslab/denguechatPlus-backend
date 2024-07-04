# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Queries
        module QueryHelper
          def direction_with_null_position
            "#{sort[:direction]} #{nulls_position}"
          end

          def sort_by_status_and_name(relation, table_name = nil)
            relation = relation.order(sort.values.join(' ').to_s)
            return relation if sort[:field] == 'name'
            return relation.order("name #{sort[:direction]}") if table_name.nil?

            relation.order("#{table_name}.name #{sort[:direction]}")
          end

          def sort_by_table_columns(relation)
            relation.order(sort.values.join(' ').to_s)
          end

          def sort_by_table_columns_with_null_position(relation)
            relation.order(sort.values.push(nulls_position).join(' ').to_s)
          end

          private

          def nulls_position
            position = sort[:direction] == 'desc' ? 'LAST' : 'FIRST'
            "NULLS #{position}"
          end
        end
      end
    end
  end
end