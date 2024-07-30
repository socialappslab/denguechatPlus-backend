# == Schema Information
#
# Table name: special_places
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class SpecialPlace < ApplicationRecord
  include Discard::Model

end
