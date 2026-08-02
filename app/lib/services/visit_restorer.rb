# frozen_string_literal: true

module Services
  class VisitRestorer
    def self.call!(...)
      new(...).call!
    end

    def initialize(visit:)
      @visit = visit
    end

    def call!
      return visit unless visit.discarded?

      house = visit.house
      ApplicationRecord.transaction do
        house.with_lock do
          visit.undiscard!
          VisitStateReconciler.call!(
            house:,
            affected_dates: [VisitStateReconciler.reporting_date(visit.visited_at)]
          )
          restore_points!
        end
      end

      visit
    end

    private

    attr_reader :visit

    def restore_points!
      return unless point_eligible?

      visit_id = visit.id
      return if Point.exists?(visit_id:)

      Api::V1::Points::Services::Transactions.assign_point(
        earner: visit.user_account,
        house_id: visit.house_id,
        visit_id:
      )
    end

    def point_eligible?
      minimum = AppConfigParam.find_by(name: 'consecutive_green_statuses_for_tariki_house')&.value.to_i
      return false unless minimum.positive?

      statuses = statuses_ending_at_visit(minimum)
      statuses.length >= minimum && statuses.all?(Constants::RiskColor::GREEN)
    end

    def statuses_ending_at_visit(limit)
      house_id = visit.house_id
      if AppConfigParam.exists?(name: 'tariki_point_same_date', value: 1)
        Visit.where(house_id:)
             .where(created_at: ..visit.created_at)
             .order(created_at: :desc, id: :desc)
             .limit(limit)
             .pluck(:status)
      else
        date = VisitStateReconciler.reporting_date(visit.visited_at)
        return [] unless date

        HouseStatus.where(house_id:, date: ..date)
                   .order(date: :desc, created_at: :desc, id: :desc)
                   .limit(limit)
                   .pluck(:status)
      end
    end
  end
end
