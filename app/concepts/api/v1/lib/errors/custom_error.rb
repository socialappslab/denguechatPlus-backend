module Api
  module V1
    module Lib
      module Errors
        class CustomError
          attr_reader :field, :messages, :meta, :path, :custom_predicate, :resource

          def initialize(field, messages, meta, path, custom_predicate, resource)
            @field = field
            @messages = messages
            @meta = meta
            @path = path
            @custom_predicate = custom_predicate
            @resource = resource
          end

          def to_array
            [self]
          end
        end
      end
    end
  end
end
