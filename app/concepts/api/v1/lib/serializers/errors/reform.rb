# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Serializers
        module Errors
          class Reform < Api::V1::Lib::Serializers::Errors::Base
            def initialize(errors, **)
              super()
              @errors = errors
            end

            def serializable_hash
              { errors: parse_errors(errors).flatten }
            end

            private

            attr_reader :errors

            def parse_errors(errors_hash)
              errors_hash.each_with_object([]) do |(field, error_value), memo|
                if plain_errors?(error_value)
                  memo << compose_errors(error_value, field)
                else
                  parse_nested_errors_arrays_array(error_value, field, memo)
                end
              end
            end

            def parse_nested_errors_arrays_array(errors_arrays_array, pointer, memo)
              errors_arrays_array.each do |errors_array|
                new_pointer = "#{pointer}/#{errors_array.first}"
                nested_errors = errors_array.second

                if plain_errors?(nested_errors)
                  memo << compose_errors(nested_errors, new_pointer)
                else
                  parse_nested_errors_hash(nested_errors, new_pointer, memo)
                end
              end
            end

            def parse_nested_errors_hash(errors_hash, pointer, memo)
              errors_hash.each do |key, error|
                new_pointer = "#{pointer}/#{key}"

                if error.is_a?(::Hash)
                  parse_nested_errors_hash(error, new_pointer, memo)
                else
                  memo << compose_errors(error, new_pointer)
                end
              end
            end

            def plain_errors?(errors)
              errors.first.is_a?(::String)
            end
          end
        end
      end
    end
  end
end
