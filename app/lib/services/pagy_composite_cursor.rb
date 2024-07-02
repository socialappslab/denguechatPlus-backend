# frozen_string_literal: true

module Services
  class PagyCompositeCursor
    def self.call(collection, options = {})
      new(collection, options).call
    end

    def initialize(collection, options = {})
      @collection = collection
      @options = options
    end

    def call
      pagy = PagyCompositeCursor::Paginator.new(collection, cursor, cursor.position)
      items = pagy.paginate
      cursor.has_more = pagy_cursor_has_more?(items, pagy)

      [cursor, items[0..pagy.items - 1]]
    end

  private

    attr_reader :collection, :options

    def cursor_options
      options.merge(primary_key: collection.primary_key)
    end

    def cursor
      @cursor ||= PagyCompositeCursor::Cursor.new(cursor_options)
    end

  # Has more without querying again
  # https://github.com/Uysim/pagy-cursor/pull/19
    def pagy_cursor_has_more?(items, pagy)
      return false if items.empty?

      items.size > pagy.items
    end
  end
end
