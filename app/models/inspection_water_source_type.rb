# == Schema Information
#
# Table name: inspection_water_source_types
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  inspection_id        :bigint           not null
#  water_source_type_id :bigint           not null
#
# Indexes
#
#  idx_on_inspection_id_water_source_type_id_36033ead1d         (inspection_id,water_source_type_id) UNIQUE
#  index_inspection_water_source_types_on_inspection_id         (inspection_id)
#  index_inspection_water_source_types_on_water_source_type_id  (water_source_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (inspection_id => inspections.id)
#  fk_rails_...  (water_source_type_id => water_source_types.id)
#
class InspectionWaterSourceType < ApplicationRecord
  belongs_to :inspection
  belongs_to :water_source_type
end
