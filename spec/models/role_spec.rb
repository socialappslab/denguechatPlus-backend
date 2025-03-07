# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  discarded_at  :datetime
#  name          :string
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :bigint
#
# Indexes
#
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#  index_roles_on_resource                                (resource_type,resource_id)
#
RSpec.describe UserAccount do
  context 'fields' do
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:password_digest).of_type(:string) }
    it { is_expected.to have_db_column(:confirmed_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:confirmation_sent_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:locked).of_type(:boolean) }
    it { is_expected.to have_db_column(:locked_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:discarded_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'indexes' do
    it { is_expected.to have_db_index(:email).unique }
    it { is_expected.to have_db_index(:discarded_at) }
  end

  it { is_expected.to have_secure_password }

  context 'relations' do
    it { is_expected.to belong_to(:user_profile).optional }
  end

  context 'delegated methods' do
    it { is_expected.to delegate_method(:first_name).to(:user_profile) }
    it { is_expected.to delegate_method(:last_name).to(:user_profile) }
    it { is_expected.to delegate_method(:gender).to(:user_profile) }
    it { is_expected.to delegate_method(:phone_number).to(:user_profile) }
    it { is_expected.to delegate_method(:slug).to(:user_profile) }
    it { is_expected.to delegate_method(:points).to(:user_profile) }
    it { is_expected.to delegate_method(:country).to(:user_profile) }
    it { is_expected.to delegate_method(:city).to(:user_profile) }
    it { is_expected.to delegate_method(:language).to(:user_profile) }
    it { is_expected.to delegate_method(:timezone).to(:user_profile) }
  end
end
