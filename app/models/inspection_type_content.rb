# frozen_string_literal: true

class InspectionTypeContent < ApplicationRecord
  self.table_name = 'inspections_type_contents'
  belongs_to :inspection
  belongs_to :type_content
end
