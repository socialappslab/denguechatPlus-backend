# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  role_id         :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_user_profiles_roles_on_role_id          (role_id)
#  index_user_profiles_roles_on_user_profile_id  (user_profile_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
class UserProfilesRole < ApplicationRecord
  belongs_to :user_profile
  belongs_to :role
end
