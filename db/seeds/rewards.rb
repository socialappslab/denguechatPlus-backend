# frozen_string_literal: true

require 'stringio'
require_relative '../files/rewards'

reward_images = REWARD_TYPES_DATA.flat_map do |type|
  type[:levels].map { |level| Rails.root.join('db/files/images/rewards', level[:image]) }
end
skin_codes = REWARD_TYPES_DATA.find { |type| type[:code] == 'skin' }[:levels].pluck(:code)
avatar_images = AVATAR_BASE_CODES.flat_map do |base_code|
  [base_code, *skin_codes.map { |skin| "#{base_code}-#{skin}" }].map do |name|
    Rails.root.join('db/files/images/avatars', "#{name}.png")
  end
end
missing_images = (reward_images + avatar_images).reject(&:readable?)
raise "Missing catalog images: #{missing_images.join(', ')}" if missing_images.any?

attach_image = ->(record, path) do
  next if record.image.attached?

  record.image.attach(io: StringIO.new(File.binread(path)), filename: path.basename.to_s, content_type: 'image/png')
end

ApplicationRecord.transaction do
  REWARD_TYPES_DATA.each do |type_data|
    reward_type = RewardType.find_or_create_by!(code: type_data[:code]) do |record|
      record.assign_attributes(type_data.except(:levels))
    end

    type_data[:levels].each do |level_data|
      level = reward_type.reward_levels.find_or_create_by!(code: level_data[:code]) do |record|
        record.assign_attributes(level_data.except(:image))
      end
      attach_image.call(level, Rails.root.join('db/files/images/rewards', level_data[:image]))
    end
  end

  skins = RewardLevel.joins(:reward_type).where(reward_types: { code: 'skin' }).to_a
  AVATAR_BASE_CODES.each_with_index do |base_code, index|
    [nil, *skins].each do |skin|
      avatar = Avatar.find_or_create_by!(base_code:, reward_level_id: skin&.id) do |record|
        record.position = index + 1
      end
      filename = skin ? "#{base_code}-#{skin.code}.png" : "#{base_code}.png"
      attach_image.call(avatar, Rails.root.join('db/files/images/avatars', filename))
    end
  end

  %w[create_reward_types_and_levels create_avatars].each do |task_name|
    SeedTask.find_or_create_by!(task_name:)
  end
end
