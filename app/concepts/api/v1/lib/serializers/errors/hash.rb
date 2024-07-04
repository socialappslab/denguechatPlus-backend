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
              res = if first_form
                [[error.text], error.path.first, nil, error.meta, set_code_error(error) ]
              else
                [error[:messages], error[:field], error[:title], error[:meta] ]
              end
            end

            def set_code_error(error)
              return '' if error.nil?
              return '' if error.try(:predicate) && error.meta.blank? && error.try(:custom_predicate)
              meta = error.meta.is_a?(::Hash)  && error.meta.key?(:predicate) ? error.meta[:predicate] : nil

              text = error.try(:predicate) || meta || error.try(:custom_predicate)
              Constants::ErrorCodes::CODE[text] || ''
            end
          end
        end
      end
    end
  end
end
