# frozen_string_literal: true

# == Schema Information
#
# Table name: points
#
#  id              :bigint           not null, primary key
#  value           :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  house_id        :integer
#  team_id         :integer
#  user_account_id :integer
#
# Indexes
#
#  index_points_on_team_id                      (team_id)
#  index_points_on_user_account_id              (user_account_id)
#  index_points_on_user_account_id_and_team_id  (user_account_id,team_id)
#
class Point < ApplicationRecord

  belongs_to :user_account
  belongs_to :team

end
