# frozen_string_literal: true

user_profile = UserProfile.create(first_name: 'John',
                                  last_name: 'Doe',
                                  gender: 'm',
                                  phone_number: '595985123456',
                                  slug: 'john-doe',
                                  points: 100,
                                  country: 'Paraguay',
                                  city: 'Encarnacion',
                                  language: 'es',
                                  timezone: 'America/Asuncion')

user_profile.create_user_account(email: 'john_doe@denguechatplus.com',
                                 password: ENV.fetch('PASSWORD_USER_DEFAULT', nil),
                                 password_confirmation: ENV.fetch('PASSWORD_USER_DEFAULT', nil),
                                 confirmed_at: Time.zone.now)
