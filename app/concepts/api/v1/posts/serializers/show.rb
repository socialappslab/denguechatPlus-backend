# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Serializers
        class Show < ApplicationSerializer
          set_type :post

          attributes :id, :visibility, :content, :created_at, :team_id, :country_id, :city_id, :neighborhood_id,
                     :location, :comments_count

          attribute :likesCount do |post|
            post.likes.size
          end

          attribute :like_by_me do |post|
            next unless post.respond_to?(:current_user_id) || post.instance_variable_get(:@current_user_id)

            current_user_id = post.respond_to?(:current_user_id) ? post.current_user_id : post.instance_variable_get(:@current_user_id)
            post.likes.any? { |like| like.user_account_id == current_user_id }
          end

          attribute :canDeleteByUser do |post|
            next unless post.respond_to?(:current_user_id) || post.instance_variable_get(:@current_user_id)

            current_user_id = post.respond_to?(:current_user_id) ? post.current_user_id : post.instance_variable_get(:@current_user_id)
            current_user = UserAccount.find_by(id: current_user_id)

            next true if current_user.has_role?(:admin) || current_user.has_role?(:team_leader)

            post.user_account_id == current_user_id
          end

          attribute :canEditByUser do |post|
            next unless post.respond_to?(:current_user_id) || post.instance_variable_get(:@current_user_id)

            current_user_id = post.respond_to?(:current_user_id) ? post.current_user_id : post.instance_variable_get(:@current_user_id)
            post.user_account_id == current_user_id
          end

          attribute :created_by do |post|
            next if post.user_account_id.blank?

            user_account = UserAccount.with_discarded.find(post.user_account_id)

            {
              accountId: post.user_account_id,
              userName: user_account.first_name,
              lastName: user_account.last_name
            }
          end

          attribute :photoUrl do |post|
            next unless post.photos.attached?

            photo = post.photos.first
            {
              photo_url: Rails.application.routes.url_helpers.url_for(photo)
            }
          end

          attribute :comments do |post|
            current_user_id = post.respond_to?(:current_user_id) ? post.current_user_id : post.instance_variable_get(:@current_user_id)
            current_user = UserAccount.with_discarded.find_by(id: current_user_id)
            is_admin = current_user.has_role?(:admin)
            is_team_leader = current_user.has_role?(:team_leader)
            post.comments.map do |comment|
              comment.instance_variable_set(:@current_user_id, current_user_id)
              comment.instance_variable_set(:@current_user_is_admin, is_admin)
              comment.instance_variable_set(:@is_team_leader, is_team_leader)
              Api::V1::Comments::Serializers::Show.new(comment).serializable_hash
            end
          end
        end
      end
    end
  end
end
