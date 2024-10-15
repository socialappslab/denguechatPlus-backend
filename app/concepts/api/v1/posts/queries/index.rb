# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Queries
        class Index
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort, current_user, source)
            @model = @posts = Post.with_attached_photos.includes(user_account: :user_profile, comments: :user_account)
            @filter = filter
            @sort = sort
            @current_user = current_user
            @source = source
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:visibility_clause))
                  .yield_self(&method(:team_clause))
                  .yield_self(&method(:like_by_me))
                  .yield_self(&method(:sector_id_clause))
                  .yield_self(&method(:sort_clause))
          end

          private

          attr_reader :posts, :filter, :sort

          def visibility_clause(relation)
            return relation if @current_user.has_role?(:admin)

            relation.where(
              'visibility = ? OR (visibility = ? AND team_id = ?)',
              'public', 'team', (@current_user.teams&.first&.id || 0)
            )
          end

          def team_clause(relation)
            return relation if @source == 'web'
            return relation if @current_user.has_role?(:admin) && @filter.blank?

            return relation.where(city_id: @current_user.city_id) if @filter.nil? || @filter[:team_id].blank?

            relation.where(team_id: @filter[:team_id])
          end

          def like_by_me(relation)
            return relation if @current_user.nil?

            relation.joins(
              "LEFT OUTER JOIN likes ON likes.likeable_type = \'Post\' AND likes.likeable_id = posts.id AND likes.user_account_id = #{@current_user.id}"
            ).select("posts.*, CASE WHEN likes.user_account_id = #{@current_user.id} THEN true ELSE false END AS like_by_me")
          end

          def sector_id_clause(relation)
            return relation if @source == 'mobile'
            return relation if @filter.nil? || @filter[:sector_id].blank?

            relation.where(neighborhood_id: @filter[:sector_id])
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            sort_by_table_columns(relation) if @sort[:field]
          end
        end
      end
    end
  end
end
