# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Serializers
        module Errors
          class Data
            def initialize(field, message, title, meta, error_code)
              @field = field
              @message = message
              @title = title
              @meta = meta
              @error_code = error_code
            end

            def data
              {
                **(title ? { title: } : {}),
                error_code: @error_code,
                detail: message,
                field: field
              }
            end

            private

            attr_reader :field, :message, :title, :meta, :error_code

            # :reek:NilCheck
            def pointer
              return if field.nil?

              "/data/attributes/#{field.to_s.dasherize}"
            end
          end
        end
      end
    end
  end
end
