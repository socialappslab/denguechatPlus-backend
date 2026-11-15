# frozen_string_literal: true

module Api
  module V1
    module Avatars
      module Serializers
        class Index < ApplicationSerializer
          set_type :avatar

          attributes :id, :base_code, :position

          image_url = lambda do |avatar|
            Rails.application.routes.url_helpers.url_for(avatar.image) if avatar.image.attached?
          end

          attribute :image_url do |avatar|
            image_url.call(avatar)
          end

          attribute :variants do |avatar|
            Avatar.kept.where(base_code: avatar.base_code).where.not(reward_level_id: nil).with_attached_image
                  .map { |variant| { rewardLevelId: variant.reward_level_id, imageUrl: image_url.call(variant) } }
          end
        end
      end
    end
  end
end
