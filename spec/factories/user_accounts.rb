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
FactoryBot.define do
  factory :user_account do
    email { FFaker::Internet.unique.email }
    password { 'Password1' }
    password_confirmation { password }
    user_profile { nil }
    locked { false }
    locked_at { nil }
    discarded_at { nil }
    confirmed_at { Time.current }

    trait :with_profile do
      user_profile { association(:user_profile) }
    end

    trait :deactivated do
      discarded_at { Time.zone.now }
    end

    trait :locked do
      locked { true }
    end
  end
end
