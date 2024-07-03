# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Serializers
        module Errors
          class Data
            def initialize(field, message, title, meta)
              @field = field
              @message = message
              @title = title
              @meta = meta
            end

            def data
              {
                **(title ? { title: } : {}),
                detail: message,
                **(meta ? { meta: } : {}),
                source: {
                  pointer:
                }
              }
            end

            private

            attr_reader :field, :message, :title, :meta

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
