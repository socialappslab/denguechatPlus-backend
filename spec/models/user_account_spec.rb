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
RSpec.describe UserAccount do
  context 'fields' do
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:password_digest).of_type(:string) }
    it { is_expected.to have_db_column(:confirmed_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:discarded_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:banned).of_type(:boolean) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'indexes' do
    it { is_expected.to have_db_index(:email).unique }
    it { is_expected.to have_db_index(:discarded_at) }
  end

  it { is_expected.to have_secure_password }

  context 'relations' do
    it { is_expected.to belong_to(:patient_profile) }
  end

  context 'delegated methods' do
    it { is_expected.to delegate_method(:first_name).to(:patient_profile) }
    it { is_expected.to delegate_method(:last_name).to(:patient_profile) }
  end
end
