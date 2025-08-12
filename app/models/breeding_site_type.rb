# == Schema Information
#
# Table name: breeding_site_types
#
#  id             :bigint           not null, primary key
#  container_type :string
#  discarded_at   :datetime
#  name           :string
#  name_en        :string
#  name_pt        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class BreedingSiteType < ApplicationRecord
  include Discard::Model
  alias_attribute :name_es, :name
end
