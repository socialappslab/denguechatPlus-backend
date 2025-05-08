# frozen_string_literal: true

module Api
  module V1
    module Points
      module Queries
        class AccumulatedPoints
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter, sort)
            @model = Point
            @filter = filter
            @sort = sort
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:by_user))
                  .yield_self(&method(:by_team))
                  .yield_self(&method(:by_date))
                  .yield_self(&method(:sort_clause)).reorder(nil)
          end

          private

          attr_reader :filter, :sort

          def by_user(relation)
            return relation if @filter.nil? || @filter[:user_account_id].blank?

            relation.joins('INNER JOIN user_accounts ON user_accounts.id = points.pointable_id')
                    .joins('INNER JOIN user_profiles ON user_profiles.id = user_accounts.user_profile_id')
                    .where(pointable_type: 'UserAccount', pointable_id: @filter[:user_account_id])
                    .group('user_accounts.id, user_profiles.first_name, user_profiles.last_name')
                    .select("user_accounts.id,
                  user_profiles.first_name || ' ' || user_profiles.last_name AS full_name,
                  SUM(points.value) AS total_points")
          end

          def by_team(relation)
            return relation if @filter.nil? || @filter[:team_id].blank?

            relation.where(pointable_id: @filter[:team_id])
                    .joins('INNER JOIN teams ON teams.id = points.pointable_id')
                    .group('teams.id, teams.name')
                    .select("teams.id,
                teams.name AS name,
                SUM(points.value) as total_points")
          end

          def by_date(relation)
            return relation if @filter.nil? || (@filter[:from_date].blank? && @filter[:to_date].blank?)

            if @filter[:from_date].present? && @filter[:to_date].present?
              start_date = @filter[:from_date].beginning_of_day
              end_date = @filter[:to_date].end_of_day
              relation.where(created_at: start_date..end_date)
            elsif @filter[:from_date].present?
              start_date = @filter[:from_date].beginning_of_day
              relation.where('points.created_at >= ?', start_date)
            else
              end_date = @filter[:to_date].end_of_day
              relation.where('points.created_at <= ?', end_date)
            end
          end

          def sort_clause(relation)
            return relation if @sort.nil? || @sort.blank?

            case @sort[:field]
            when 'points'
              relation.order("total_points #{@sort[:direction] || 'DESC'}")
            when 'name'
              relation.order("name #{@sort[:direction] || 'ASC'}")
            else
              relation
            end
          end
        end
      end
    end
  end
end
