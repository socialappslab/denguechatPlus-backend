# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Serializers
        class BulkUpload < ApplicationSerializer
          set_type :bulk_upload
          set_id { 'bulk_upload' }

          attribute :visit_ids do |object|
            object[:visit_ids]
          end
        end
      end
    end
  end
end
