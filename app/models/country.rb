# == Schema Information
#
# Table name: countries
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_countries_on_discarded_at  (discarded_at)
#  index_countries_on_name          (name)
#
class Country < ApplicationRecord
  include Discard::Model

  has_many :states, dependent: :destroy
  accepts_nested_attributes_for :states, allow_destroy: true
end
