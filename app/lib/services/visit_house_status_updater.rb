# frozen_string_literal: true

module Services
  class VisitHouseStatusUpdater
    def self.apply!(visit:, house:, last_visit_at:, denied_without_inspections: Constants::RiskColor::YELLOW)
      status = RiskColorCalculator.visit_status(visit, denied_without_inspections:)
      counts = if visit.inspections.any?
                 RiskColorCalculator.inspection_counts(visit.inspections.group(:color).count)
               else
                 { infected_containers: 0, potential_containers: 0, non_infected_containers: 0 }
               end

      house.update!(
        **counts,
        last_visit: last_visit_at,
        status:,
        tariki_status: house.tariki?(status)
      )
      visit.update!(status:)
    end
  end
end
