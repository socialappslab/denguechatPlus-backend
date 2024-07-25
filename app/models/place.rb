# == Schema Information
#
# Table name: place
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Place < ApplicationRecord
  include Discard::Model
end
