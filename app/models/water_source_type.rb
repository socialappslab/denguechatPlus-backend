# == Schema Information
#
# Table name: elimination_method_types
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class WaterSourceType < ApplicationRecord
  include Discard::Model
end
