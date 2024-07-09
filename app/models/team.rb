# == Schema Information
#
# Table name: teams
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  discarded_at    :datetime
#  locked          :boolean          default(FALSE)
#  name            :string
#  points          :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  neighborhood_id :bigint
#  organization_id :bigint           not null
#
# Indexes
#
#  index_teams_on_name_and_deleted_at  (name,deleted_at) UNIQUE
#  index_teams_on_neighborhood_id      (neighborhood_id)
#  index_teams_on_organization_id      (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class Team < ApplicationRecord
  include Discard::Model

  belongs_to :organization
  belongs_to :neighborhood, optional: true
  has_many :team_members, dependent: :destroy

  accepts_nested_attributes_for :team_members, allow_destroy: true

end
