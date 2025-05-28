# frozen_string_literal: true

# == Schema Information
#
# Table name: user_accounts
#
#  id                    :bigint           not null, primary key
#  code_recovery_sent_at :datetime
#  discarded_at          :datetime
#  failed_attempts       :integer          default(0)
#  password_digest       :string
#  phone                 :string
#  status                :integer          default("pending")
#  username              :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_profile_id       :bigint
#
# Indexes
#
#  index_user_accounts_on_discarded_at     (discarded_at)
#  index_user_accounts_on_phone            (phone) UNIQUE
#  index_user_accounts_on_user_profile_id  (user_profile_id)
#  index_user_accounts_on_username         (username) UNIQUE
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

    trait :without_confirmation do
      confirmed_at { nil }
    end

    trait :locked do
      locked { true }
    end
  end
end
