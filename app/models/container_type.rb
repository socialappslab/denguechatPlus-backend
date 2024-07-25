# == Schema Information
#
# Table name: container_types
#
#  id                    :bigint           not null, primary key
#  discarded_at          :datetime
#  name                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  breeding_site_type_id :bigint           not null
#
# Indexes
#
#  index_container_types_on_breeding_site_type_id  (breeding_site_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (breeding_site_type_id => breeding_site_types.id)
#
class ContainerType < ApplicationRecord
  include Discard::Model

  belongs_to :breeding_site_type
  has_one_attached :photo
end
