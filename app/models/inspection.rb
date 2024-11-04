# == Schema Information
#
# Table name: inspections
#
#  id                         :bigint           not null, primary key
#  code_reference             :string
#  container_test_result      :string
#  has_water                  :boolean
#  lid_type                   :string
#  lid_type_other             :string
#  other_elimination_method   :string
#  other_protection           :string
#  tracking_type_required     :string
#  was_chemically_treated     :string
#  water_source_other         :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  breeding_site_type_id      :bigint           not null
#  container_protection_id    :bigint
#  created_by_id              :bigint           not null
#  elimination_method_type_id :bigint           not null
#  treated_by_id              :bigint           not null
#  visit_id                   :bigint           not null
#  water_source_type_id       :bigint
#
# Indexes
#
#  index_inspections_on_breeding_site_type_id       (breeding_site_type_id)
#  index_inspections_on_container_protection_id     (container_protection_id)
#  index_inspections_on_created_by_id               (created_by_id)
#  index_inspections_on_elimination_method_type_id  (elimination_method_type_id)
#  index_inspections_on_treated_by_id               (treated_by_id)
#  index_inspections_on_visit_id                    (visit_id)
#  index_inspections_on_water_source_type_id        (water_source_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (breeding_site_type_id => breeding_site_types.id)
#  fk_rails_...  (container_protection_id => container_protections.id)
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
  belongs_to :container_protection, optional: true
  has_many :inspection_type_contents, dependent: :nullify
  has_many :type_contents, through: :inspection_type_contents
  has_one_attached :photo


  def potential?
    container_protection.present? && ['Tapa no hermética', 'Techo', 'Otro', 'No tiene'].include?(container_protection.name_es)
  end

  def infected?
    type_contents.exists?(name_es: %w[Larva Pupas Huevos])
  end

  def self.inspection_summary_for(inspection_ids)
    res = select(
      "SUM(CASE WHEN type_contents.name_es IN ('Larva', 'Pupas', 'Huevos') THEN 1 ELSE 0 END) AS infected_containers",
      "SUM(CASE WHEN container_protections.name_es IN ('Tapa no hermética', 'Techo', 'Otro', 'No tiene') THEN 1 ELSE 0 END) AS potential_containers",
      "SUM(CASE WHEN (type_contents.name_es NOT IN ('Larva', 'Pupas', 'Huevos') OR type_contents.name_es IS NULL) AND (container_protections.name_es NOT IN ('Tapa no hermética', 'Techo', 'Otro', 'No tiene') OR container_protections.name_es IS NULL) THEN 1 ELSE 0 END) AS non_infected_containers"
    )
      .joins("LEFT JOIN container_protections ON inspections.container_protection_id = container_protections.id")
      .joins("LEFT JOIN inspections_type_contents ON inspections.id = inspections_type_contents.inspection_id")
      .joins("LEFT JOIN type_contents ON inspections_type_contents.type_content_id = type_contents.id")
      .where(id: inspection_ids)
      .group(
        "CASE WHEN type_contents.name_es IN ('Larva', 'Pupas', 'Huevos') THEN 'Infected' ELSE 'Non-Infected' END",
        "CASE WHEN container_protections.name_es IN ('Tapa no hermética', 'Techo', 'Otro', 'No tiene') THEN 'Potential' ELSE 'Non-Potential' END"
      )
      .order("infected_containers DESC, potential_containers DESC")


    return {infected_containers: 0, potential_containers: 0, non_infected_containers: 0} if res.nil?

    res.first.attributes.symbolize_keys.except(:id)

  end



end
