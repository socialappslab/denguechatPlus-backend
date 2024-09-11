# frozen_string_literal: true

class InspectionTypeContent < ApplicationRecord
  belongs_to :inspection
  belongs_to :type_content
end
