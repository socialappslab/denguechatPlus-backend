# frozen_string_literal: true

module Services
  class VisitDuplicateCandidateRepairer
    DEFAULT_BATCH_SIZE = 100

    def initialize(batch_size: DEFAULT_BATCH_SIZE, output: $stdout)
      @batch_size = batch_size
      @output = output
      @processed = 0
      @failed = 0
    end

    def call
      output.puts("Houses to process: #{House.count}")
      report_candidate_rows('before')
      House.find_each(batch_size:) { |house| repair_house(house) }
      report_candidate_rows('after')
      output.puts("Processed houses: #{processed}; failed houses: #{failed}")
      { processed:, failed: }
    end

    private

    attr_reader :batch_size, :failed, :output, :processed

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
