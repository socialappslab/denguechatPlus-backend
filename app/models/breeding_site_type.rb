# == Schema Information
#
# Table name: breeding_site_types
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class BreedingSiteType < ApplicationRecord
  include Discard::Model
end
