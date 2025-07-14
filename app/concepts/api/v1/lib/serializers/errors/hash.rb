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
              if error.respond_to?(:text) # if a dry error validation
                [[error.text], error.path.last, nil, error.meta, set_code_error(error)]
              else # or is a custom error validator
                [[error.messages], error.field, '', error.meta, set_code_error(error)]
              end
            end

            def set_code_error(error)
              return '' if error.nil?

              error.try(:resource) ? set_unauthorized(error) : set_field_code_error(error)
            end

            def set_field_code_error(error)
              return '' if error.nil?
              return '' if error.try(:predicate) && error.meta.blank? && error.try(:custom_predicate)

              meta = error.try(:meta) && error.meta.is_a?(::Hash) && error.meta.key?(:predicate) ? error.meta[:predicate] : nil

              text = error.try(:predicate) || meta || error.try(:custom_predicate)
              Constants::ErrorCodes::CODE[text] || ''
            end

            def set_unauthorized(error)
              resource = error.try(:resource)
              return '' if resource.nil? || resource.blank?

              Constants::PermissionCodes::CODE.fetch(resource.to_sym)
            end
          end
        end
      end
    end
  end
end
