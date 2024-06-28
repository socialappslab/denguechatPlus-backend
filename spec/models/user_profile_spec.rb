# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id           :bigint           not null, primary key
#  city         :string
#  country      :string
#  first_name   :string
#  gender       :integer
#  language     :string
#  last_name    :string
#  phone_number :string
#  points       :integer
#  slug         :string
#  timezone     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
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
