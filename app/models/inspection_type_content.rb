# == Schema Information
#
# Table name: inspections_type_contents
#
#  inspection_id   :bigint
#  type_content_id :bigint
#
# Indexes
#
#  index_inspections_type_contents_on_inspection_id    (inspection_id)
#  index_inspections_type_contents_on_type_content_id  (type_content_id)
#
# Foreign Keys
#
#  fk_rails_...  (inspection_id => inspections.id)
#  fk_rails_...  (type_content_id => type_contents.id)
#
# frozen_string_literal: true

# == Schema Information
#
# Table name: inspections_type_contents
#
#  inspection_id   :bigint
#  type_content_id :bigint
#
# Indexes
#
#  index_inspections_type_contents_on_inspection_id    (inspection_id)
#  index_inspections_type_contents_on_type_content_id  (type_content_id)
#
# Foreign Keys
#
#  fk_rails_...  (inspection_id => inspections.id)
#  fk_rails_...  (type_content_id => type_contents.id)
#
class InspectionTypeContent < ApplicationRecord
  self.table_name = 'inspections_type_contents'
  belongs_to :inspection
  belongs_to :type_content
end
