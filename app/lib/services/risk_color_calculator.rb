# frozen_string_literal: true

module Services
  class RiskColorCalculator
    def self.inspection_color(has_water:, type_content_ids:, container_protection_ids:)
      return Constants::RiskColor::GREEN unless has_water

      type_content_ids = Array(type_content_ids).map(&:to_i).reject(&:zero?)
      container_protection_ids = Array(container_protection_ids).map(&:to_i).reject(&:zero?)
      return Constants::RiskColor::GREEN if type_content_ids.empty? && container_protection_ids.empty?

      clauses = []
      values = []

      if type_content_ids.any?
        clauses << "(questions.resource_name = 'type_content_id' AND options.resource_id IN (?))"
        values << type_content_ids
      end

      if container_protection_ids.any?
        clauses << "(questions.resource_name = 'container_protection_ids' AND options.resource_id IN (?))"
        values << container_protection_ids
      end

      results = Option.joins(:question)
                      .where(clauses.join(' OR '), *values)
                      .group(:status_color)
                      .sum(:weighted_points)

      results.key(results.values.max) || Constants::RiskColor::GREEN
    end

    def self.aggregate_from_counts(counts)
      return Constants::RiskColor::RED if (counts[Constants::RiskColor::RED] || 0).positive?
      return Constants::RiskColor::YELLOW if (counts[Constants::RiskColor::YELLOW] || 0).positive?

      Constants::RiskColor::GREEN
    end

    def self.inspection_counts(counts)
      {
        infected_containers: counts[Constants::RiskColor::RED] || 0,
        potential_containers: counts[Constants::RiskColor::YELLOW] || 0,
        non_infected_containers: counts[Constants::RiskColor::GREEN] || 0
      }
    end

    def self.visit_status(visit, denied_without_inspections: Constants::RiskColor::YELLOW)
      return aggregate_from_counts(visit.inspections.group(:color).count) if visit.inspections.any?
      return Constants::RiskColor::GREEN if visit.visit_permission_granted?

      denied_without_inspections
    end
  end
end
