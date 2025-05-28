# == Schema Information
#
# Table name: inspections
#
#  id                         :bigint           not null, primary key
#  code_reference             :string
#  color                      :string
#  container_test_result      :string
#  discarded_at               :datetime
#  has_water                  :boolean
#  lid_type                   :string
#  lid_type_other             :string
#  location                   :string
#  other_elimination_method   :string
#  other_protection           :string
#  tracking_type_required     :string
#  was_chemically_treated     :string
#  water_source_other         :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  breeding_site_type_id      :bigint           not null
#  created_by_id              :bigint           not null
#  elimination_method_type_id :bigint
#  treated_by_id              :bigint           not null
#  visit_id                   :bigint           not null
#
# Indexes
#
#  index_inspections_on_breeding_site_type_id       (breeding_site_type_id)
#  index_inspections_on_created_by_id               (created_by_id)
#  index_inspections_on_discarded_at                (discarded_at)
#  index_inspections_on_elimination_method_type_id  (elimination_method_type_id)
#  index_inspections_on_treated_by_id               (treated_by_id)
#  index_inspections_on_visit_id                    (visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (breeding_site_type_id => breeding_site_types.id)
#  fk_rails_...  (created_by_id => user_accounts.id)
#  fk_rails_...  (elimination_method_type_id => elimination_method_types.id)
#  fk_rails_...  (treated_by_id => user_accounts.id)
#  fk_rails_...  (visit_id => visits.id)
#
class Inspection < ApplicationRecord
  belongs_to :visit
  belongs_to :breeding_site_type, optional: true
  belongs_to :elimination_method_type, optional: true
  belongs_to :created_by, class_name: 'UserAccount'
  belongs_to :treated_by, class_name: 'UserAccount'
  has_many :inspection_container_protections
  has_many :container_protections, through: :inspection_container_protections
  has_many :inspection_type_contents, dependent: :nullify
  has_many :type_contents, through: :inspection_type_contents
  has_many :inspection_water_source_types, dependent: :destroy
  has_many :water_source_types, through: :inspection_water_source_types
  has_one_attached :photo

  has_paper_trail on: [:update]

  def potential?
    container_protection.present? && ['Tapa no hermética', 'Si, tiene tapa pero no está bien cerrado', 'Techo', 'Otro',
                                      'No tiene'].include?(container_protection.name_es)
  end

  def infected?
    type_contents.exists?(name_es: %w[Larva Pupas Huevos])
  end

  def status_i18n(selected_value = 'verde', lang = 'es')
    case lang
    when 'es'
      [
        {
          name: 'verde',
          value: 'green',
          selected: selected_value == 'green'
        },
        {
          name: 'amarillo',
          value: 'yellow',
          selected: selected_value == 'yellow'
        },
        {
          name: 'rojo',
          value: 'red',
          selected: selected_value == 'red'
        }
      ]
    when 'en'
      [
        {
          name: 'green',
          value: 'green',
          selected: selected_value == 'green'
        },
        {
          name: 'yellow',
          value: 'yellow',
          selected: selected_value == 'yellow'
        },
        {
          name: 'red',
          value: 'red',
          selected: selected_value == 'red'
        }
      ]
    when 'pt'
      [
        {
          name: 'verde',
          value: 'green',
          selected: selected_value == 'green'
        },
        {
          name: 'amarelo',
          value: 'yellow',
          selected: selected_value == 'yellow'
        },
        {
          name: 'vermelho',
          value: 'red',
          selected: selected_value == 'red'
        }
      ]
    else
      [
        {
          name: 'verde',
          value: 'green',
          selected: selected_value == 'green'
        },
        {
          name: 'amarillo',
          value: 'yellow',
          selected: selected_value == 'yellow'
        },
        {
          name: 'rojo',
          value: 'red',
          selected: selected_value == 'red'
        }
      ]
    end
  end
end
