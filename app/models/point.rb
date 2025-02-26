# frozen_string_literal: true

# == Schema Information
#
# Table name: points
#
#  id             :bigint           not null, primary key
#  pointable_type :string
#  value          :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  house_id       :integer
#  pointable_id   :bigint
#  visit_id       :integer
#
# Indexes
#
#  index_points_on_pointable_type_and_pointable_id  (pointable_type,pointable_id)
#
class Point < ApplicationRecord
  belongs_to :pointable, polymorphic: true
  scope :for_teams, -> { where(pointable_type: 'Team') }
  scope :for_users, -> { where(pointable_type: 'UserAccount') }
end
