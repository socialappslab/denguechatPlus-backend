# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Serializers
        module Errors
          class Base
            def serialized_json
              ActiveSupport::JSON.encode(serializable_hash)
            end

            def serializable_hash
              raise 'Please implement this method at subclass'
            end

            private

            def compose_errors(messages, field, title = nil, meta = nil, error_code)
              messages.map do |message|
                Api::V1::Lib::Serializers::Errors::Data.new(field, message, title, meta, error_code).data
              end
            end
          end
        end
      end
    end
  end
end
