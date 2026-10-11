# frozen_string_literal: true

module Services
  class VisitDuplicateCandidateRepairer
    DEFAULT_BATCH_SIZE = 100

    def initialize(dry_run: true, batch_size: DEFAULT_BATCH_SIZE, output: $stdout)
      @dry_run = dry_run
      @batch_size = batch_size
      @output = output
      @processed = 0
      @failed = 0
    end

    def call
      output.puts("Houses to process: #{House.count}")
      report_candidate_rows('before')

      return dry_run_summary if dry_run

      House.find_each(batch_size:) { |house| repair_house(house) }
      report_candidate_rows('after')
      output.puts("Processed houses: #{processed}; failed houses: #{failed}")
      { processed:, failed: }
    end

    private

    attr_reader :batch_size, :dry_run, :failed, :output, :processed

    def dry_run_summary
      output.puts('Dry run only. Set APPLY=true to reconcile data.')
      { processed: 0, failed: 0 }
    end

    def report_candidate_rows(stage)
      output.puts("Candidate rows #{stage} repair: #{VisitDuplicateCandidate.count}")
    end

    def repair_house(house)
      house_id = house.id
      Services::VisitDuplicateCandidateReconciler.rebuild_house!(house_id:)
      @processed += 1
    rescue StandardError => error
      @failed += 1
      output.puts("House #{house_id} failed: #{error.message}")
    end
  end
end
