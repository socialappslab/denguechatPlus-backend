# == Schema Information
#
# Table name: breeding_site_type_aditional_informations
#
#  id                    :bigint           not null, primary key
#  description           :string
#  only_image            :boolean
#  subtitle              :string
#  title                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  breeding_site_type_id :bigint           not null
#
# Indexes
#
#  idx_on_breeding_site_type_id_a588ef2362  (breeding_site_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (breeding_site_type_id => breeding_site_types.id)
#
class BreedingSiteTypeAditionalInformation < ApplicationRecord
  belongs_to :breeding_site_type
  has_one_attached :image
end
