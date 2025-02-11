# == Schema Information
#
# Table name: container_protections
#
#  id           :bigint           not null, primary key
#  color        :string
#  discarded_at :datetime
#  name_en      :string
#  name_es      :string
#  name_pt      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class ContainerProtection < ApplicationRecord
  include Discard::Model

  # has_many :inspections, dependent: :nullify
  has_many :inspection_container_protections
  has_many :inspections, through: :inspection_container_protections
end
