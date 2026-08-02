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
        end
      end

      visit
    end

    private

    attr_reader :visit
  end
end
