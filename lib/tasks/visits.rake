# frozen_string_literal: true

namespace :visits do
  desc 'Restore a discarded visit and reconcile its derived state'
  task :restore, [:visit_id] => :environment do |_task, args|
    abort('visit_id is required') if args[:visit_id].blank?

    visit = Visit.with_discarded.find(args[:visit_id])
    Services::VisitRestorer.call!(visit:)
    puts("Visit #{visit.id} is active and its derived state is reconciled.")
  end

  desc 'Repair visit-derived house state (dry-run by default; use APPLY=true to persist)'
  task repair_state: :environment do
    dry_run = ENV.fetch('APPLY', 'false') != 'true'
    batch_size = [ENV.fetch('BATCH_SIZE', Services::VisitStateRepairer::DEFAULT_BATCH_SIZE).to_i, 1].max
    result = Services::VisitStateRepairer.new(dry_run:, batch_size:).call
    abort("Repair completed with #{result[:failed]} failed houses") if result[:failed].positive?
  end
end
