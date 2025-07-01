# == Schema Information
#
# Table name: inspection_elimination_method_types
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  elimination_method_type_id :bigint           not null
#  inspection_id              :bigint           not null
#
# Indexes
#
#  idx_on_elimination_method_type_id_a7873ece3f                (elimination_method_type_id)
#  idx_on_inspection_id_elimination_method_type_id_42c6e6636a  (inspection_id,elimination_method_type_id) UNIQUE
#  index_inspection_elimination_method_types_on_inspection_id  (inspection_id)
#
# Foreign Keys
#
#  fk_rails_...  (elimination_method_type_id => elimination_method_types.id)
#  fk_rails_...  (inspection_id => inspections.id)
#
class InspectionEliminationMethodType < ApplicationRecord
  belongs_to :inspection
  belongs_to :elimination_method_type
end
