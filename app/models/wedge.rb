# == Schema Information
#
# Table name: wedges
#
#  id             :bigint           not null, primary key
#  discarded_at   :datetime
#  last_sync_time :datetime
#  name           :string
#  source         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :integer
#
class Wedge < ApplicationRecord
  include Discard::Model

  has_many :neighborhood_wedges, dependent: :destroy
  has_many :neighborhoods, through: :neighborhood_wedges
  has_many :house_blocks
end
