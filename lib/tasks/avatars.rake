# frozen_string_literal: true

namespace :data_migration do
  desc 'Assign catalog avatar-1 to profiles without an avatar; run after db:seed'
  task backfill_default_avatar: :environment do
    updated = UserProfile.backfill_default_avatar!
    puts "Assigned avatar-1 to #{updated} profiles. Existing avatar and skin selections preserved."
  end
end
