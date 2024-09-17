# == Schema Information
#
# Table name: type_contents
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name_en      :string
#  name_es      :string
#  name_pt      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class TypeContent < ApplicationRecord
  has_many :inspection_type_contents, dependent: :destroy
  has_many :inspections, through: :inspection_type_contents
end
