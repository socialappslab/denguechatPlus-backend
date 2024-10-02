# frozen_string_literal: true

module Api
  module V1
    module Comments
      module Serializers
        class Show < ApplicationSerializer
          set_type :comment

          attributes :id, :content, :created_at, :updated_at

          attribute :likesCount do |comment|
            comment.likes.count
          end

          attribute :liked_by_me do |comment|
            comment.likes.exists?(user_account_id: comment.user_account_id)
          end

          attribute :created_by do |comment|
            next if comment.user_account_id.blank?

            {
              accountId: comment.user_account_id,
              userName: comment.user_account.first_name,
              lastName: comment.user_account.last_name,
            }
          end

          attribute :photos do |comment|
            next unless comment.photo.attached?

            {
              photo_url: Rails.application.routes.url_helpers.url_for(comment.photo)
            }
          end
        end
      end
    end
  end
end
