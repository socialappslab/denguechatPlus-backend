# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class BulkUpload < Dry::Validation::Contract
          params do
            required(:file).filled
          end

          rule(:file) do
            key.failure(text: 'File is required', predicate: :filled?) if value.nil?

            next if value.nil?

            original_filename = value.respond_to?(:original_filename) ? value.original_filename : value.to_s
            content_type = value.respond_to?(:content_type) ? value.content_type : nil

            unless original_filename&.downcase&.end_with?('.xlsx')
              key.failure(text: 'Only .xlsx files are accepted', predicate: :invalid_format?)
            end

            if content_type && content_type != 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
              key.failure(text: 'Invalid MIME type for .xlsx', predicate: :invalid_format?)
            end
          end
        end
      end
    end
  end
end
