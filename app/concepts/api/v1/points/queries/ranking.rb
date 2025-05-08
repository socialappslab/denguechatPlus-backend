# frozen_string_literal: true

module Api
  module V1
    module Points
      module Queries
        class Ranking
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
            @model.yield_self(&method(:by_date))
                  .yield_self(&method(:by_user))
                  .yield_self(&method(:by_team))
                  .yield_self(&method(:sort_and_limit))
          end

          private

          attr_reader :filter, :sort

          def by_user(relation)
            return relation if @filter.nil? || @filter[:type].blank? || @filter[:type] != 'users'

            relation.joins(user_account: :user_profile)
                    .group("user_accounts.id, user_profiles.first_name || ' ' || user_profiles.last_name")
                    .select("user_accounts.id,
                            user_profiles.first_name || ' ' || user_profiles.last_name AS full_name,
                            COUNT(DISTINCT house_id) as total_sites,
                            SUM(points.value) as total_points")
          end

          def by_team(relation)
            return relation if @filter.nil? || @filter[:type].blank? || @filter[:type] != 'teams'

            relation.joins(:team)
                    .group('teams.id, teams.name')
                    .select("teams.id,
                            teams.name AS name,
                            COUNT(DISTINCT house_id) as total_sites,
                            SUM(points.value) as total_points")
          end

          def by_date(relation)
            return relation if @filter.nil? || @filter[:date].blank?

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

          def sort_and_limit(relation)
            limit = @filter&.[](:limit).present? ? @filter[:limit] : 10
            relation.order('SUM(points.value) DESC').limit(limit)
          end
        end
      end
    end
  end
end
