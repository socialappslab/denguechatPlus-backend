# == Schema Information
#
# Table name: inspections
#
#  id                         :bigint           not null, primary key
#  code_reference             :string
#  container_test_result      :string
#  has_lid                    :boolean
#  has_water                  :boolean
#  tracking_type_required     :string
#  was_chemically_treated     :boolean
#  water_source_other         :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  breeding_site_type_id      :bigint           not null
#  created_by_id              :bigint           not null
#  elimination_method_type_id :bigint           not null
#  treated_by_id              :bigint           not null
#  visit_id                   :bigint           not null
#  water_source_type_id       :bigint           not null
#
# Indexes
#
#  index_inspections_on_breeding_site_type_id       (breeding_site_type_id)
#  index_inspections_on_created_by_id               (created_by_id)
#  index_inspections_on_elimination_method_type_id  (elimination_method_type_id)
#  index_inspections_on_treated_by_id               (treated_by_id)
#  index_inspections_on_visit_id                    (visit_id)
#  index_inspections_on_water_source_type_id        (water_source_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (breeding_site_type_id => breeding_site_types.id)
#  fk_rails_...  (created_by_id => user_accounts.id)
#  fk_rails_...  (elimination_method_type_id => elimination_method_types.id)
#  fk_rails_...  (treated_by_id => user_accounts.id)
#  fk_rails_...  (visit_id => visits.id)
#  fk_rails_...  (water_source_type_id => water_source_types.id)
#
class Inspection < ApplicationRecord
  belongs_to :visit
  belongs_to :breeding_site_type
  belongs_to :elimination_method_type
  belongs_to :water_source_type
  belongs_to :created_by, class_name: 'UserAccount'
  belongs_to :treated_by, class_name: 'UserAccount'
end
