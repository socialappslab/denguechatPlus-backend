# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Serializers
        class NamingConvention
          attr_reader :res

          def initialize(params, type = :to_camel_case)
            case type
            when :to_camel_case
              @res = to_camel_case(params)
            when :to_snake_case
              @res = to_snake_case(params)
            end
          end

          private

          def to_snake_case(params)
            case params
            when Hash
              params.transform_keys { |key| key.to_s.underscore }.transform_values do |value|
                to_snake_case(value)
              end
            when Array
              params.map { |value| to_snake_case(value) }
            else
              params
            end
          end

          def to_camel_case(params)
            params.transform_keys do |key|
              key.to_s.camelize(:lower)
            end.transform_values do |value|
              value.is_a?(Hash) ? to_camel_case(value) : value
            end
          end
        end
      end
    end
  end
end
