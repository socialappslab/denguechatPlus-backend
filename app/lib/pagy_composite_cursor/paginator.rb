# frozen_string_literal: true

module PagyCompositeCursor
  class Paginator
    def initialize(collection, pagy, position)
      @collection = collection
      @pagy = pagy
      @position = position
    end

    def paginate
      reverse? ? paginated_collection.reverse : paginated_collection.to_a
    end

    def more?
      paginated_collection.exists?
    end

    private

    attr_reader :collection, :pagy, :position

    delegate :items, :order, :primary_key, :comparation, :composite_key, :reverse?, to: :pagy
    delegate :arel_table, to: :collection

    def paginated_collection
      collection
        .yield_self(&method(:position_clause))
        .yield_self(&method(:paginate_clause))
    end

    def position_clause(relation)
      return relation if cursor_entry.blank?

      relation.where(sql_comparation)
    end

    # Has more without querying again
    # https://github.com/Uysim/pagy-cursor/pull/19
    def paginate_clause(relation)
      relation.reorder(order).limit(items + 1)
    end

    def sql_comparation
      return primary_key_comparation unless composite_key && !nested_composite_key?

      composite_key_comparation = arel_composite_key.eq(select_composite_key).and(primary_key_comparation)
      arel_composite_key.public_send(comparation, select_composite_key).or(composite_key_comparation)
    end

    def primary_key_comparation
      arel_primary_key.send(comparation, position)
    end

    def select_composite_key
      cursor_entry.send(composite_key)
    end

    def cursor_entry
      @cursor_entry ||= collection.find_by(arel_primary_key.eq(position))
    end

    def arel_composite_key
      Arel.sql(composite_key.to_s)
    end

    def arel_primary_key
      arel_table[primary_key]
    end

    def nested_composite_key?
      return false if composite_key.is_a?(Symbol)

      composite_key.count('.').positive?
    end
  end
end
