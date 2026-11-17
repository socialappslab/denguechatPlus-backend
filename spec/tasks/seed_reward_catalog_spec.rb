# frozen_string_literal: true

require 'spec_helper'
require 'rake'

RSpec.describe 'data_migration:seed_reward_catalog' do # rubocop:disable RSpec/DescribeClass
  let(:task) { Rake::Task['data_migration:seed_reward_catalog'] }

  before do
    Rails.application.load_tasks unless Rake::Task.task_defined?('data_migration:seed_reward_catalog')
  end

  def seed_catalog
    task.reenable
    task.invoke
  end

  it 'creates the complete catalog and its image attachments without running unrelated seeds' do
    seed_catalog

    expect(RewardType.pluck(:code)).to contain_exactly('skin', 'star')
    expect(RewardLevel.count).to eq(8)
    expect(Avatar.catalog.count).to eq(4)
    expect(Avatar.count).to eq(16)
    expect(ActiveStorage::Attachment.where(name: 'image').count).to eq(24)
    expect(SeedTask.pluck(:task_name)).to contain_exactly('create_reward_types_and_levels', 'create_avatars')
    expect(UserReward.count).to eq(0)
    expect(UserAccount.count).to eq(0)
  end

  it 'preserves catalog records and attachments when repeated' do
    seed_catalog
    snapshots = [RewardType, RewardLevel, Avatar, SeedTask, ActiveStorage::Blob, ActiveStorage::Attachment]
                .to_h { |model| [model, model.order(:id).map(&:attributes)] }

    seed_catalog

    snapshots.each do |model, attributes|
      expect(model.order(:id).map(&:attributes)).to eq(attributes)
    end
  end

  it 'repairs a partial catalog despite existing markers and preserves customized definitions' do
    type = RewardType.create!(code: 'skin', metric: 'worked_houses', name_es: 'Custom prizes')
    level = type.reward_levels.create!(code: 'skin-polo', threshold: 75, name_es: 'Custom polo')
    avatar = Avatar.create!(base_code: 'avatar-2', position: 9)
    %w[create_reward_types_and_levels create_avatars].each { |name| SeedTask.create!(task_name: name) }

    seed_catalog

    expect(RewardLevel.count).to eq(8)
    expect(Avatar.count).to eq(16)
    expect(type.reload.name_es).to eq('Custom prizes')
    expect(level.reload.threshold).to eq(75)
    expect(avatar.reload.position).to eq(9)
    expect(level.image).to be_attached
    expect(avatar.image).to be_attached
  end

  it 'rolls back catalog records and markers if creation fails' do
    allow(Avatar).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordInvalid)

    expect { seed_catalog }.to raise_error(ActiveRecord::RecordInvalid)

    expect(RewardType.count).to eq(0)
    expect(RewardLevel.count).to eq(0)
    expect(Avatar.count).to eq(0)
    expect(ActiveStorage::Attachment.count).to eq(0)
    expect(SeedTask.count).to eq(0)
  end

  it 'preserves user avatar choices and existing reward notifications' do
    seed_catalog
    country = Country.create!(name: 'Catalog test')
    state = State.create!(name: 'Catalog test', country:)
    city = City.create!(name: 'Catalog test', country:, state:)
    neighborhood = Neighborhood.create!(name: 'Catalog test', country:, state:, city:)
    organization = Organization.create!(name: 'Catalog test')
    skin = RewardLevel.find_by!(code: 'skin-polo')
    avatar = Avatar.catalog.find_by!(base_code: 'avatar-2')
    profile = UserProfile.create!(city:, neighborhood:, organization:, avatar:,
                                  equipped_reward_level: skin, skin_manually_chosen: true)
    account = UserAccount.create!(username: 'catalog-test', password: 'password123', user_profile: profile)
    award = UserReward.create!(earner: account, reward_level: skin, earned_at: Time.current, count_at_earn: 50,
                               notifiable: true)
    profile_attributes = profile.attributes
    award_attributes = award.attributes

    seed_catalog

    expect(profile.reload.attributes).to eq(profile_attributes)
    expect(award.reload.attributes).to eq(award_attributes)
  end
end
