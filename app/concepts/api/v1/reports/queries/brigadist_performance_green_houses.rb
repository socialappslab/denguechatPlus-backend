# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Queries
        class BrigadistPerformanceGreenHouses
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter)
            @model = ::Visit
            @filter = filter || {}
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model
              .yield_self(&method(:get_first_five))
          end

          def get_first_five(relation)
            latest_statuses = latest_statuses_query
            relation
              .joins('INNER JOIN (' + latest_statuses + ') AS latest_statuses ON visits.house_id = latest_statuses.house_id AND visits.visited_at = latest_statuses.latest_date')
              .joins(user_account: :user_profile)
              .select('user_accounts.id AS user_account_id, COUNT(visits.id) AS quantity, user_profiles.first_name, user_profiles.last_name')
              .where('visits.status = ?', 'Verde')
              .group('user_accounts.id, user_profiles.first_name, user_profiles.last_name')
              .order('quantity DESC')
              .limit(5)
          end

          private

          def latest_statuses_query
            <<-SQL
              SELECT#{' '}
                house_id,#{' '}
                MAX(visits.visited_at) AS latest_date
              FROM visits
              GROUP BY house_id
            SQL
          end
        end
      end
    end
  end
end
