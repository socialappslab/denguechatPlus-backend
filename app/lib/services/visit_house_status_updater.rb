# frozen_string_literal: true

module Services
  class VisitHouseStatusUpdater
    def self.apply_and_tariki_reached?(visit:, house:, last_visit_at:,
                                       denied_without_inspections: Constants::RiskColor::YELLOW)
      previous_tariki_status = house.tariki_status
      status = RiskColorCalculator.visit_status(visit, denied_without_inspections:)
      counts = RiskColorCalculator.inspection_counts(visit.inspections.group(:color).count)

      visit.update!(status:)
      house.update!(
        **counts,
        last_visit: last_visit_at,
        status:
      )
      TarikiStatusRecalculator.recalculate!(house)

      !previous_tariki_status && house.tariki_status?
    end
  end
end
