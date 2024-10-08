# == Schema Information
#
# Table name: elimination_method_types
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name_en      :string
#  name_es      :string
#  name_pt      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class EliminationMethodType < ApplicationRecord
  include Discard::Model
end
