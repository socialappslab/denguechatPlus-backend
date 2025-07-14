# == Schema Information
#
# Table name: water_source_types
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  name_en      :string
#  name_pt      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class WaterSourceType < ApplicationRecord
  include Discard::Model
  has_many :inspection_water_source_types
  has_many :inspections, through: :inspection_water_source_types
  alias_attribute :name_es, :name
end
