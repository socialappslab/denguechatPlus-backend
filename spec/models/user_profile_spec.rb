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
    it { is_expected.to have_db_column(:country).of_type(:string) }
    it { is_expected.to have_db_column(:city).of_type(:string) }
    it { is_expected.to have_db_column(:citizen_id).of_type(:string) }
    it { is_expected.to have_db_column(:date_of_birth).of_type(:datetime) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:phone_number).of_type(:string) }
    it { is_expected.to have_db_column(:wellness).of_type(:boolean) }

    it { is_expected.to define_enum_for(:gender).with_values({ female: 0, male: 1, other: 2 }) }
    it { is_expected.to define_enum_for(:onboarding_status).with_values({ general_info: 0, completed: 1 }) }
  end

  context 'relations' do
    it { is_expected.to have_one(:patient_account).dependent(:destroy) }
    it { is_expected.to have_one(:chat_user).dependent(:destroy) }
    it { is_expected.to have_one(:health_profile).dependent(:destroy) }
    it { is_expected.to have_one(:patient_balance).dependent(:nullify) }
    it { is_expected.to have_one(:patient_feedback).dependent(:destroy) }
    it { is_expected.to have_one(:notification_setting).dependent(:destroy) }
    it { is_expected.to have_one(:app_review).dependent(:destroy) }
    it { is_expected.to have_many(:extra_free_visits).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_many(:chats).through(:chat_user) }
    it { is_expected.to have_many(:appointments).dependent(:nullify) }
    it { is_expected.to have_many(:questionnaire_responses).dependent(:nullify) }
    it { is_expected.to have_many(:notes).dependent(:nullify) }
    it { is_expected.to have_many(:vouchers).dependent(:nullify) }
    it { is_expected.to have_many(:video_conferences).through(:appointments) }
    it { is_expected.to have_many(:video_conference_events).dependent(:destroy) }
    it { is_expected.to have_many(:pagopar_orders).dependent(:nullify) }
    it { is_expected.to have_many(:registered_devices).dependent(:destroy) }
  end

  context 'delegated methods' do
    it { is_expected.to delegate_method(:email).to(:patient_account).allow_nil }
    it { is_expected.to delegate_method(:confirmed_at).to(:patient_account).allow_nil }
  end
end
