# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Serializers
        class Show < ApplicationSerializer
          set_type :post

          attributes :id, :visibility, :content, :created_at, :team_id, :country_id, :city_id, :neighborhood_id, :location, :comments_count

          attribute :likesCount do |post|
            post.likes.size
          end

          attribute :like_by_me do |post|
            next unless post.respond_to?(:current_user_id) || post.instance_variable_get(:@current_user_id)

            current_user_id = post.respond_to?(:current_user_id) ? post.current_user_id : post.instance_variable_get(:@current_user_id)
            post.likes.any? { |like| like.user_account_id == current_user_id}
          end

          attribute :canDeleteByUser do |post|
            next unless post.respond_to?(:current_user_id) || post.instance_variable_get(:@current_user_id)

            current_user_id = post.respond_to?(:current_user_id) ? post.current_user_id : post.instance_variable_get(:@current_user_id)
            post.user_account_id == current_user_id
          end

          attribute :canEditByUser do |post|
            next unless post.respond_to?(:current_user_id) || post.instance_variable_get(:@current_user_id)

            current_user_id = post.respond_to?(:current_user_id) ? post.current_user_id : post.instance_variable_get(:@current_user_id)
            post.user_account_id == current_user_id
          end

          attribute :created_by do |post|
            next if post.user_account_id.blank?

            {
              accountId: post.user_account_id,
              userName: post.user_account.first_name,
              lastName: post.user_account.last_name,
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
            current_user = UserAccount.find_by(id: current_user_id)
            is_admin = current_user.has_role?(:admin)
            teams_managed = current_user.has_role?(:team_leader) ? current_user.teams_under_leadership : []
            post.comments.map do |comment|
              comment_owner = UserAccount.find_by(id: comment.user_account_id)
              is_team_leader = teams_managed.include?(comment_owner.teams.first&.id)
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
