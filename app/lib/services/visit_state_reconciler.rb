# frozen_string_literal: true

module Services
  class VisitStateReconciler
    REPORTING_TIME_ZONE = 'America/Lima'

    def self.call!(...)
      new(...).call!
    end

    def self.reporting_date(visited_at)
      return if visited_at.blank?

      visited_at.in_time_zone(REPORTING_TIME_ZONE).to_date
    end

    def initialize(house:, affected_dates: [])
      @house = house
      @affected_dates = Array(affected_dates).compact.uniq
    end

    def call!
      affected_dates.each { |date| reconcile_daily_status!(date) }
      reconcile_current_status!
      house
    end

    private

    attr_reader :affected_dates, :house

    def reconcile_daily_status!(date)
      house_statuses = HouseStatus.where(house_id: house.id, date:)
      visit = latest_active_visit(visits_on(date))
      unless visit
        house_statuses.destroy_all
        return
      end

      status, counts = status_and_counts(visit)
      house_status = house_statuses.first_or_initialize
      house_status.assign_attributes(
        infected_containers: counts[:infected_containers],
        non_infected_containers: counts[:non_infected_containers],
        potential_containers: counts[:potential_containers],
        city_id: house.city_id,
        country_id: house.country_id,
        house_block_id: house.house_blocks.find_by(block_type: 'frente_a_frente')&.id,
        neighborhood_id: house.neighborhood_id,
        team_id: visit.team_id,
        wedge_id: house.wedge_id,
        last_visit: visit.visited_at,
        status:
      )
      house_status.save!
      house_statuses.where.not(id: house_status.id).destroy_all
    end

    def reconcile_current_status!
      visit = latest_active_visit(Visit.where(house_id: house.id))
      unless visit
        clear_current_status!
        return
      end

      status, counts = status_and_counts(visit)
      house.update!(
        **counts,
        last_visit: visit.visited_at,
        status:
      )
      TarikiStatusRecalculator.recalculate!(house)
    end

    def clear_current_status!
      house.update!(
        infected_containers: 0,
        non_infected_containers: 0,
        potential_containers: 0,
        last_visit: nil,
        status: nil
      )
      TarikiStatusRecalculator.recalculate!(house)
    end

    def visits_on(date)
      zone = Time.find_zone!(REPORTING_TIME_ZONE)
      range = zone.local(date.year, date.month, date.day).all_day
      Visit.where(house_id: house.id, visited_at: range)
    end

    def latest_active_visit(relation)
      relation.latest_first.first
    end

    def status_and_counts(visit)
      snapshot = RiskColorCalculator.visit_snapshot(visit)
      stored_status = visit.status
      status = stored_status.presence || snapshot[:status]
      visit.update!(status:) if stored_status.blank?

      [status, snapshot[:counts]]
    end
  end
end
