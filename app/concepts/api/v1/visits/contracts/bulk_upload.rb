# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class BulkUpload < Dry::Validation::Contract
          ALLOWED_MIME_TYPES = %w[application/vnd.openxmlformats-officedocument.spreadsheetml.sheet].freeze
          ALLOWED_EXTENSIONS = %w[.xlsx].freeze

          def self.kall(...)
            new.call(...)
          end

          params do
            required(:file).filled
          end

          rule(:file) do
            unless value.respond_to?(:tempfile)
              key.failure(text: 'must be a valid file upload', predicate: :format?)
              next
            end

            key.failure(text: 'must be an .xlsx Excel file', predicate: :format?) unless valid_mime_type?(value)
            key.failure(text: 'must have an .xlsx extension', predicate: :format?) unless valid_extension?(value)
          end

          private

          def valid_mime_type?(file)
            return false unless file.respond_to?(:content_type)

            ALLOWED_MIME_TYPES.include?(file.content_type)
          end

          def valid_extension?(file)
            return false unless file.respond_to?(:original_filename)

            ALLOWED_EXTENSIONS.include?(File.extname(file.original_filename).downcase)
          end
        end
      end
    end
  end
end
