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
FactoryBot.define do
  factory :user_profile do
    transient do
      password { 'Password1' }
    end

    first_name { FFaker::Name.unique.first_name }
    last_name { FFaker::Name.unique.last_name }
    country { FFaker::Address.country }
    city { FFaker::Address.city }

    trait :with_chat_user do
      after(:create) do |user_profile, _evaluator|
        create(:chat_user, chatable: user_profile)
      end
    end

    trait :with_account do
      transient do
        password { 'Password1' }
        email { FFaker::Internet.email }
        discarded_at { nil }
        banned { false }
        confirmed_at { Time.current }
      end

      phone_number { "#{FFaker::PhoneNumber.area_code}#{FFaker::PhoneNumber.short_phone_number.delete('-')}" }
      citizen_id { FFaker::IdentificationPL.pesel }
      date_of_birth { FFaker::Time.datetime }
      gender { %w[female male].sample }

      after(:create) do |user_profile, evaluator|
        create(
          :user_account,
          user_profile:,
          password: evaluator.password,
          email: evaluator.email || FFaker::Internet.unique.email,
          discarded_at: evaluator.discarded_at,
          banned: evaluator.banned,
          confirmed_at: evaluator.confirmed_at
        )
      end
    end

    trait :with_health_profile do
      after(:create) do |user_profile|
        create(:health_profile, user_profile:)
      end
    end

    trait :with_app_review do
      transient do
        rate { nil }
        rated_at { nil }
      end

      after(:create) do |user_profile, evaluator|
        create(:app_review, rate: evaluator.rate, rated_at: evaluator.rated_at, user_profile:)
      end
    end

    trait :with_children do
      transient do
        children_count { 2 }
      end

      after(:create) do |user_profile, evaluator|
        create_list(:child_profile, evaluator.children_count, user_profile:)
      end
    end

    trait :with_appointments do
      transient do
        appointments_amount { 3 }
        appointments { nil }
        user_profile { nil }
      end

      after(:create) do |user_profile, evaluator|
        next(user_profile.appointments.push(evaluator.appointments)) if evaluator.appointments

        create_list(
          :appointment,
          evaluator.appointments_amount,
          user_profile: evaluator.user_profile || create(:user_profile, :with_account),
          user_profile:
        )
      end
    end

    trait :with_user_balance do
      transient do
        balance { rand(15_000..100_000) }
        free_visits { 0 }
      end

      after(:create) do |user_profile, evaluator|
        create(
          :user_balance,
          balance: evaluator.balance,
          free_visits: evaluator.free_visits,
          user_profile:
        )
      end
    end

    trait :with_notification_setting do
      transient do
        push_notifications { true }
      end

      after(:create) do |user_profile, evaluator|
        create(:notification_setting, recipient: user_profile,
                                      push_notifications: evaluator.push_notifications)
      end
    end

    trait :with_read_notifications do
      transient do
        notifications_count { 2 }
      end

      after(:create) do |user_profile, evaluator|
        user_profile.notifications.create(
          attributes_for_list(
            :notification,
            evaluator.notifications_count,
            :read
          )
        )
      end
    end

    trait :with_registered_devices do
      transient do
        registered_devices_count { 1 }
      end

      after(:create) do |user_profile, evaluator|
        user_profile.registered_devices.create(
          attributes_for_list(
            :registered_device,
            evaluator.registered_devices_count
          )
        )
      end
    end

    trait :with_extra_free_visits do
      transient do
        free_visits_count { rand(1..99) }
        extra_free_visits_clinic { create(:virtual_clinic, accept_extra_free_visits: true) }
      end

      after(:create) do |user_profile, evaluator|
        create(:extra_free_visit, free_visits_count: evaluator.free_visits_count,
                                  user_profile:,
                                  clinic: evaluator.extra_free_visits_clinic)
      end
    end
  end
end
