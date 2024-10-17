# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Queries
        class Show
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(current_user, source, params)
            @model = @posts = Post.with_attached_photos.includes(:likes, user_account: :user_profile, comments: %i[user_account likes])
            @current_user = current_user
            @source = source
            @params = params || {}
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:by_id))
                  .yield_self(&method(:visibility_clause))
                  .yield_self(&method(:like_by_me))
                  .yield_self(&method(:can_delete_by_me))
                  .yield_self(&method(:current_user_id))
          end

          private

          attr_reader :posts

          def by_id(relation)
            return relation if @params.nil? || @params[:id].nil?

            relation.where(id: @params[:id])
          end

          def visibility_clause(relation)
            return relation if @current_user.has_role?(:admin)

            relation.where(
              'visibility = ? OR (visibility = ? AND team_id = ?)',
              'public', 'team', (@current_user.teams&.first&.id || 0)
            )
          end

          def like_by_me(relation)
            return relation if @current_user.nil?

            relation.left_joins(:likes).select("posts.*, CASE WHEN likes.user_account_id = #{@current_user.id} THEN true ELSE false END AS like_by_me")
          end

          def can_delete_by_me(relation)
            return relation if @current_user.nil?
            team_ids = @current_user.teams_under_leadership
            team_ids = team_ids.any? ? team_ids.join(', ') : '0'



            relation.select("posts.*,
                CASE
                  WHEN posts.user_account_id = #{@current_user.id} THEN true
                  WHEN #{@current_user.has_role?(:admin)} THEN true
                  WHEN #{@current_user.has_role?(:team_leader)} THEN true
                ELSE false
                END AS can_delete_by_me")

          end

          def current_user_id(relation)
            return nil if @current_user.nil?

            relation.select("posts.*, #{@current_user.id} AS current_user_id")
          end

        end
      end
    end
  end
end
