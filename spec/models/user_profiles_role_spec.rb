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
#  index_user_profiles_roles_on_user_profile_id  (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
RSpec.describe UserProfilesRole do

  context 'indexes' do
    it { is_expected.to have_db_index(:role_id) }
    it { is_expected.to have_db_index(:user_profile_id) }
  end

  context 'relations' do
    it { is_expected.to belong_to(:role) }
    it { is_expected.to belong_to(:user_profile) }
  end
end
