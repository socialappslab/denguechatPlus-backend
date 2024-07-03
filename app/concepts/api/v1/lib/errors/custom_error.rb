module Api
  module V1
    module Lib
      module Errors
        class CustomError
          attr_accessor :field, :text, :meta, :path

          def initialize(field, text, meta, path)
            @field = field
            @text = text
            @meta = meta
            @path = path
          end
        end
      end
    end
  end
end
