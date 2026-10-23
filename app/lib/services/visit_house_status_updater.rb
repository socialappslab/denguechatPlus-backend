# frozen_string_literal: true

module Services
  class VisitHouseStatusUpdater
    def self.apply_and_tariki_reached?(visit:, previous_house: nil, previous_visited_at: nil)
      house = visit.house
      previous_tariki_status = house.tariki_status

      visit.update!(status: RiskColorCalculator.visit_snapshot(visit)[:status])
      affected_dates = [visit.visited_at, previous_visited_at].map do |visited_at|
        VisitStateReconciler.reporting_date(visited_at)
      end
      [house, previous_house].compact.uniq.each do |affected_house|
        affected_house.with_lock { VisitStateReconciler.call!(house: affected_house, affected_dates:) }
      end

      !previous_tariki_status && house.tariki_status?
    end
  end
end
