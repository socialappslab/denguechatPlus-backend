# frozen_string_literal: true

module Api
  module V1
    module Points
      module Services
        class Transactions
          def self.assign_point(earner: nil, house_id: nil, visit_id: nil)
            return [] unless earner
            return [] unless house_id
            return [] unless visit_id

            visit = Visit.find_by(id: visit_id)
            return [] unless visit&.visited_at

            case earner
            when UserAccount
              user_account = earner
              team = visit.team
            when Team
              team = earner
              user_account = visit.user_account
            else
              return []
            end

            existing_points = earner.points.joins(:visit)
                                    .where(house_id:, visits: { visited_at: visit.visited_at.all_day })
                                    .first

            return [] if existing_points

            Point.transaction do
              [
                assign_by_earner(earner: user_account, house_id:, visit_id:),
                assign_by_earner(earner: team, house_id:, visit_id:)
              ].compact
            end
          end

          def self.assign_by_earner(earner:, house_id:, visit_id:)
            point = if earner.instance_of?(UserAccount)
                      AppConfigParam.find_by('name = ?', 'green_house_points_user_account')&.value
                    else
                      AppConfigParam.find_by('name = ?', 'green_house_points_team')&.value
                    end
            return unless point

            earner.points.create!(value: point, house_id:, visit_id:)
          end
        end
      end
    end
  end
end
