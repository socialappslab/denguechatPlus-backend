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

          attribute :photos do |post|
            next unless post.photo.attached?

            {
              photo_url: Rails.application.routes.url_helpers.url_for(post.photo)
            }
          end
        end
      end
    end
  end
end
