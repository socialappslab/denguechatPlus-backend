# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Serializers
        class Index < ApplicationSerializer
          set_type :post

          attributes :id

          attribute :createdAt do |post|
            next unless post.created_at

            post.created_at.to_i * 1000
          end

          attribute :userAccountId do |post|
            next unless post.user_account_id

            post.user_account_id
          end

          attribute :createdBy do |post|
            next unless post.user_account_id

            "#{post.user_account.first_name} #{post.user_account.last_name}"
          end

          attribute :postText do |post|
            next unless post.content

            post.content
          end

          attribute :photoUrl do |post|
            next unless post.photos.attached?

            photo = post.photos.first
            {
              photo_url: Rails.application.routes.url_helpers.url_for(photo)
            }
          end

          attribute :commentsCount do |post|
            next unless post.comments.any?

            post.comments.count
          end

          attribute :likesCount do |post|
            post.likes.count
          end

          attribute :comments do |post|
            next unless post.comments.any?

            post.comments.map do |comment|
              {
                id: comment.id,
                likesCount: comment.likes_count,
                userAccountId: comment.user_account_id,
                createdBy: "#{comment.user_account.first_name} #{comment.user_account.last_name}",
                createdAt: comment.created_at.to_i * 1000,
                commentText: comment.content,
                photo: comment.photo.attached? ? Rails.application.routes.url_helpers.url_for(comment.photo) : nil
              }
            end
          end
        end
      end
    end
  end
end
