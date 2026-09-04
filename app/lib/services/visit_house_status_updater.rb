# frozen_string_literal: true

module Services
  class VisitHouseStatusUpdater
    def self.apply_and_tariki_reached?(visit:)
      house = visit.house
      previous_tariki_status = house.tariki_status
      snapshot = RiskColorCalculator.visit_snapshot(visit)
      status = snapshot[:status]

      visit.update!(status:)
      house.update!(
        **snapshot[:counts],
        last_visit: visit.visited_at || Time.current,
        status:
      )
      TarikiStatusRecalculator.recalculate!(house)

      !previous_tariki_status && house.tariki_status?
    end
  end
end
