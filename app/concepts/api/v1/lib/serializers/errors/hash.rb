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
              if error.respond_to?(:text)
                [[error.text], error.path.last, nil, error.meta, set_field_code_error(error) ]
              else
               [error[:messages], error[:field], error[:title], error[:meta], set_unauthorized(error[:resource]) ]
             end
            end

            def set_field_code_error(error)
              return '' if error.nil?
              return '' if error.try(:predicate) && error.meta.blank? && error.try(:custom_predicate)

              meta = error.meta.is_a?(::Hash)  && error.meta.key?(:predicate) ? error.meta[:predicate] : nil

              text = error.try(:predicate) || meta || error.try(:custom_predicate)
              Constants::ErrorCodes::CODE[text] || ''
            end

            def set_unauthorized(resource)
              return '' if resource.nil? || resource.blank?

              Constants::PermissionCodes::CODE.fetch(resource, Constants::PermissionCodes::CODE.first.last)
            end
          end
        end
      end
    end
  end
end
