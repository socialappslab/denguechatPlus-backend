module Api
  module V1
    module Lib
      module Errors
        class CustomError
          attr_accessor :field, :text, :meta, :path, :custom_predicate

          def initialize(field, text, meta, path, custom_predicate=nil)
            @field = field
            @text = text
            @meta = meta
            @path = path
            @custom_predicate = custom_predicate
          end
        end
      end
    end
  end
end
