# frozen_string_literal: true

module Services
  class VisitStateRepairer
    DEFAULT_BATCH_SIZE = 100

    def initialize(dry_run: true, batch_size: DEFAULT_BATCH_SIZE, output: $stdout)
      @dry_run = dry_run
      @batch_size = batch_size
      @output = output
      @processed = 0
      @failed = 0
    end

    def call
      print_summary('Before')
      return dry_run_summary if dry_run

      House.find_each(batch_size:) { |house| repair_house(house) }
      print_summary('After')
      output.puts("Processed houses: #{processed}; failed houses: #{failed}")
      { processed:, failed: }
    end

    private

    attr_reader :batch_size, :dry_run, :failed, :output, :processed

    def dry_run_summary
      output.puts('Dry run only. Set APPLY=true to reconcile data.')
      { processed: 0, failed: 0 }
    end

    def repair_house(house)
      house_id = house.id
      ApplicationRecord.transaction do
        house.with_lock do
          discarded_visit_ids = Visit.with_discarded.discarded.where(house_id:).select(:id)
          Point.where(visit_id: discarded_visit_ids).delete_all
          VisitStateReconciler.call!(house:, affected_dates: reporting_dates(house))
        end
      end
      @processed += 1
    rescue StandardError => error
      @failed += 1
      output.puts("House #{house_id} failed: #{error.message}")
    end

    def reporting_dates(house)
      house_id = house.id
      visit_dates = Visit.with_discarded
                         .where(house_id:)
                         .where.not(visited_at: nil)
                         .pluck(:visited_at)
                         .map { |visited_at| VisitStateReconciler.reporting_date(visited_at) }
      (visit_dates + HouseStatus.where(house_id:).pluck(:date)).compact.uniq
    end

    def print_summary(label)
      houses_with_status = House.where.not(status: nil)
      discarded_visits = Visit.with_discarded.discarded
      summary = {
        houses_with_status: houses_with_status.count,
        houses_without_active_visits: houses_with_status.where.not(id: Visit.select(:house_id)).count,
        discarded_visits: discarded_visits.count,
        points_on_discarded_visits: Point.where(visit_id: discarded_visits.select(:id)).count,
        house_statuses: HouseStatus.count
      }
      output.puts("#{label}: #{summary.inspect}")
    end
  end
end
