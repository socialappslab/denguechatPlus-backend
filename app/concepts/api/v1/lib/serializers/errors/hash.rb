# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Serializers
        module Errors
          class Hash < Api::V1::Lib::Serializers::Errors::Base
            def initialize(errors, **)
              super()
              @errors = errors
            end

            def serializable_hash
              { errors: data }
            end

            private

            attr_reader :errors

            def data
              errors.map { |error| compose_errors(*compose_arguments(error)) }.flatten
            end

            def compose_arguments(error)
              first_form = error.respond_to?(:text)
              if first_form
                res =  [[error.text], error.path.first, nil, error.meta ]
              else
                res = [error[:messages], error[:field], error[:title], error[:meta] ]
              end
            end
          end
        end
      end
    end
  end
end
