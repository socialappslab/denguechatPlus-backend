# == Schema Information
#
# Table name: special_places
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name_en      :string
#  name_es      :string
#  name_pt      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class SpecialPlace < ApplicationRecord
  include Discard::Model
  alias_attribute :name, :name_es
end
