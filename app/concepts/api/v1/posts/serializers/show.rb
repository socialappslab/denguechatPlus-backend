# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Serializers
        class Show < ApplicationSerializer
          set_type :post

          attributes :id, :content, :created_at, :team_id, :country_id, :city_id, :neighborhood_id

          attribute :likesCount do |post|
            post.likes.count
          end

          attribute :photos do |post|
            next unless post.photos.attached?

            res = []

            post.photos.each do |photo|
                res << { photo_url: Rails.application.routes.url_helpers.url_for(photo) }
              end
            res
          end
        end
      end
    end
  end
end
