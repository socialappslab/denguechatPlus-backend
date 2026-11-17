# frozen_string_literal: true

namespace :data_migration do
  desc 'Initialize reward and avatar definitions and images without running unrelated seeds; safe to rerun'
  task seed_reward_catalog: :environment do
    load Rails.root.join('db/seeds/rewards.rb')
    puts "Catalog ready: #{RewardType.count} reward types, #{RewardLevel.count} levels, #{Avatar.count} avatars."
  end
end
