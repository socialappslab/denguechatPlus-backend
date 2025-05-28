# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id              :bigint           not null, primary key
#  email           :string
#  first_name      :string
#  gender          :integer
#  language        :string
#  last_name       :string
#  points          :integer
#  timezone        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  city_id         :bigint
#  neighborhood_id :bigint
#  organization_id :bigint
#  team_id         :bigint
#
# Indexes
#
#  index_user_profiles_on_city_id          (city_id)
#  index_user_profiles_on_neighborhood_id  (neighborhood_id)
#  index_user_profiles_on_organization_id  (organization_id)
#  index_user_profiles_on_team_id          (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id)
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (team_id => teams.id)
#
RSpec.describe UserProfile do
  context 'fields' do
    it { is_expected.to have_db_column(:first_name).of_type(:string) }
    it { is_expected.to have_db_column(:last_name).of_type(:string) }
    it { is_expected.to have_db_column(:gender).of_type(:integer) }
    it { is_expected.to have_db_column(:phone_number).of_type(:string) }
    it { is_expected.to have_db_column(:slug).of_type(:string) }
    it { is_expected.to have_db_column(:points).of_type(:integer) }
    it { is_expected.to have_db_column(:country).of_type(:string) }
    it { is_expected.to have_db_column(:city).of_type(:string) }
    it { is_expected.to have_db_column(:language).of_type(:string) }
    it { is_expected.to have_db_column(:timezone).of_type(:string) }
  end

  context 'relations' do
    it { is_expected.to have_one(:user_account).dependent(:destroy) }
    it { is_expected.to have_one(:user_profiles_role).dependent(:destroy) }
    it { is_expected.to have_one(:role).through(:user_profiles_role) }
  end

  context 'delegated methods' do
    it { is_expected.to delegate_method(:email).to(:user_account).allow_nil }
    it { is_expected.to delegate_method(:confirmed_at).to(:user_account).allow_nil }
  end
end
