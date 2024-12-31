# == Schema Information
#
# Table name: wedges
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Wedge < ApplicationRecord
  include Discard::Model

  has_many :neighborhood_wedges, dependent: :destroy
  has_many :neighborhoods, through: :neighborhood_wedges

end
