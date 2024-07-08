# frozen_string_literal: true

module PagyCompositeCursor
  class Cursor < Pagy
    ASC_CONDITIONS = { comparation: 'gt', order: :asc }.freeze
    DESC_CONDITIONS = { comparation: 'lt', order: :desc }.freeze

    attr_reader :before, :after, :items, :primary_key
    attr_accessor :has_more
    alias has_more? has_more

    def initialize(options)
      @before, @after, @primary_key = options.values_at(:before, :after, :primary_key)
      @items = options[:items] || Pagy::VARS[:items]
      @reorder = options[:order] || {}
    end

    def position
      before || after
    end

    def comparation
      composite_asc? ? asc_conditions[:comparation] : desc_conditions[:comparation]
    end

    def direction
      composite_asc? ? asc_conditions[:order] : desc_conditions[:order]
    end

    def order
      return default_order if composite_order.empty?

      { composite_key => direction }.merge(default_order)
    end

    def reverse?
      before.present?
    end

    def composite_key
      composite_order.keys.first
    end

    def composite_value
      composite_order.values.first
    end

    private

    attr_reader :reorder

    def default_order
      { primary_key => direction }
    end

    def composite_asc?
      composite_order.empty? || composite_value.to_sym.eql?(:asc)
    end

    def asc_conditions
      reverse? ? DESC_CONDITIONS : ASC_CONDITIONS
    end

    def desc_conditions
      reverse? ? ASC_CONDITIONS : DESC_CONDITIONS
    end

    def composite_order
      reorder.without(primary_key)
    end
  end
end
