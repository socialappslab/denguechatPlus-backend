# frozen_string_literal: true

module Services
  class VisitHouseStatusUpdater
    def self.apply_and_tariki_reached?(visit:, previous_house: nil, previous_visited_at: nil)
      house = visit.house
      houses = [house, previous_house].compact.uniq(&:id).sort_by(&:id)

      House.transaction do
        houses.each(&:lock!)
        previous_tariki_status = house.tariki_status
        visit.update!(status: RiskColorCalculator.visit_snapshot(visit)[:status])

        affected_dates = [VisitStateReconciler.reporting_date(visit.visited_at)]
        previous_date = VisitStateReconciler.reporting_date(previous_visited_at)
        if previous_house && previous_house.id != house.id
          VisitStateReconciler.call!(house: previous_house, affected_dates: [previous_date])
        else
          affected_dates << previous_date
        end
        VisitStateReconciler.call!(house:, affected_dates:)

        !previous_tariki_status && house.tariki_status?
      end
    end
  end
end
