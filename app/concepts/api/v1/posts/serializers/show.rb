# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Serializers
        class Show < ApplicationSerializer
          set_type :post

          attributes :id, :content, :created_at, :team_id, :country_id, :city_id, :neighborhood_id, :location, :comments_count

          attribute :likesCount do |post|
            post.likes.size  # use `size` instead of `count` after preloading `likes`
          end

          attribute :like_by_me do |post|
            post.likes.any? { |like| like.user_account_id == post.user_account_id }  # use `any?` instead of `exists?` after preloading `likes`
          end

          attribute :photos do |post|
            post.photos.map do |photo|
              { photo_url: Rails.application.routes.url_helpers.url_for(photo) }
            end
          end

          attribute :comments do |post|
            post.comments.map do |comment|
              Api::V1::Comments::Serializers::Show.new(comment).serializable_hash
            end
          end
        end
      end
    end
  end
end
