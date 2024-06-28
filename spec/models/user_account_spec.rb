# frozen_string_literal: true

# == Schema Information
#
# Table name: user_accounts
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmed_at         :datetime
#  discarded_at         :datetime
#  email                :string
#  locked               :boolean          default(FALSE), not null
#  locked_at            :datetime
#  password_digest      :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_profile_id      :bigint
#
# Indexes
#
#  index_user_accounts_on_discarded_at     (discarded_at)
#  index_user_accounts_on_email            (email) UNIQUE
#  index_user_accounts_on_user_profile_id  (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_profile_id => user_profiles.id)
#
RSpec.describe Role do
  context 'fields' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:resource_type).of_type(:string) }
    it { is_expected.to have_db_column(:resource_id).of_type(:integer) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'indexes' do
    it { is_expected.to have_db_index([:name, :resource_type, :resource_id]) }
  end


  context 'relations' do
    it { is_expected.to have_many(:user_profiles_roles).dependent(:destroy) }
    it { is_expected.to have_many(:user_profiles).through(:user_profiles_roles) }
    it { is_expected.to belong_to(:resource).optional }
  end

  context 'validations' do
    it { is_expected.to validate_inclusion_of(:resource_type).in_array(Rolify.resource_types) }
    it { is_expected.to validate_inclusion_of(:name).in_array(Constants::Role::ALLOWED_NAMES) }
  end
end
