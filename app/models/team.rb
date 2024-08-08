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
#  leader_id       :bigint
#  neighborhood_id :bigint
#  organization_id :bigint           not null
#  wedge_id        :bigint
#
# Indexes
#
#  index_teams_on_leader_id            (leader_id)
#  index_teams_on_name_and_deleted_at  (name,deleted_at) UNIQUE
#  index_teams_on_neighborhood_id      (neighborhood_id)
#  index_teams_on_organization_id      (organization_id)
#  index_teams_on_wedge_id             (wedge_id)
#
# Foreign Keys
#
#  fk_rails_...  (leader_id => user_profiles.id)
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (wedge_id => wedges.id)
#
class Team < ApplicationRecord
  include Discard::Model


  has_many :members, class_name: 'UserProfile'
  belongs_to :leader, class_name: 'UserProfile', optional: true
  belongs_to :organization
  belongs_to :sector, class_name: 'Neighborhood', foreign_key: 'neighborhood_id'
  belongs_to :wedge, class_name: 'Wedge'

end
