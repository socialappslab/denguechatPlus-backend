# == Schema Information
#
# Table name: inspection_container_protections
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  container_protection_id :bigint
#  inspection_id           :bigint
#
# Indexes
#
#  idx_on_container_protection_id_2b631ae959                (container_protection_id)
#  index_inspection_container_protections_on_inspection_id  (inspection_id)
#
# Foreign Keys
#
#  fk_rails_...  (container_protection_id => container_protections.id)
#  fk_rails_...  (inspection_id => inspections.id)
#
class InspectionContainerProtection < ApplicationRecord
  belongs_to :inspection
  belongs_to :container_protection
end
