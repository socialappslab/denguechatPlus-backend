# frozen_string_literal: true

module Api
  module V1
    module Points
      module Services
        class Transactions
          def self.assign_point(earner: nil, house_id: nil, visit_id: nil )
            return unless earner
            return unless house_id
            return unless visit_id

            case earner.class.name
            when 'UserAccount'
              user_account = earner
              team = Visit.find_by(id: visit_id)&.team
            when 'Team'
              team = earner
              user_account = Visit.find_by(id: visit_id)&.user_account
            else
              return
            end

            existing_points =  earner.points.where(house_id:).where("DATE(created_at)::date = ?::date", Date.current)&.first

            return if existing_points

            self.assign_by_earner(earner: user_account, house_id:, visit_id:)

            self.assign_by_earner(earner: team, house_id:, visit_id:)
          end

          def self.remove_point(earner: nil, house_id: nil, visit_id: nil)
            return unless earner
            return unless house_id
            return unless visit_id

            remove_points(earner:, house_id:, visit_id:)
          end

          private

          def self.assign_by_earner(earner:, house_id:, visit_id:)
            point = if earner.class.name == 'UserAccount'
              AppConfigParam.find_by("name = ?", "green_house_points_user_account")&.value
                    else
              AppConfigParam.find_by("name = ?", "green_house_points_team")&.value
                    end
            return unless point

            earner.points.create!(value: point, house_id: , visit_id: )
          end

          def self.remove_points(earner: nil, house_id: nil, visit_id: nil)
            visit = Visit.find_by(id: visit_id)

            Point.where(pointable_id: visit.user_account_id, pointable_type: 'UserAccount', visit_id:, house_id:).destroy_all
            Point.where(pointable_id: visit.team_id, pointable_type: 'Team', visit_id:, house_id:).destroy_all
          end

        end
      end
    end
  end
end
