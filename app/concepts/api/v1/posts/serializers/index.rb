# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Serializers
        class Index < ApplicationSerializer
          set_type :post

          attributes :id, :visibility, :team_id

          attribute :createdAt do |post|
            next unless post.created_at

            post.created_at.to_i * 1000
          end

          attribute :userAccountId do |post|
            next unless post.user_account_id

            post.user_account_id
          end

          attribute :create_by_user do |post|
            next if post.user_account_id.blank?

            user = UserAccount.with_discarded.find(post.user_account_id)

            {
              accountId: post.user_account_id,
              userName: user.first_name,
              lastName: user.last_name
            }
          end

          attribute :createdBy do |post|
            next unless post.user_account_id

            user_account = UserAccount.with_discarded.find(post.user_account_id)

            "#{user_account.first_name}, #{user_account.last_name}"
          end

          attribute :location do |post|
            next unless post.location

            post.location
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

            post.comments_count
          end

          attribute :likesCount, &:likes_count

          attribute :liked_by_user, &:like_by_me

          attribute :canDeleteByUser, &:can_delete_by_me

          attribute :canEditByUser, &:can_delete_by_me
        end
      end
    end
  end
end
