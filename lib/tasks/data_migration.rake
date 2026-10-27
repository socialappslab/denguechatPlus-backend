# frozen_string_literal: true

namespace :data_migration do
  desc 'Set the visit start house and orchard options to positions 1 and 2'
  task set_visit_start_option_positions: :environment do
    question = Question.find_by!(question_text_es: '¿Dónde comienza la visita?')
    house = question.options.find_by!(name_es: 'En la casa')
    orchard = question.options.find_by!(name_es: 'En la huerta')

    if house.position == 1 && orchard.position == 2
      puts 'Visit start options already have positions 1 and 2.'
      next
    end

    Option.transaction do
      house.update!(position: 1) unless house.position == 1
      orchard.update!(position: 2) unless orchard.position == 2
    end

    puts 'Done. En la casa: 1; En la huerta: 2.'
  end

  desc 'Set the container stage weighted points (Larvas and Pupas 1000, Huevos 100) and recalculate container, ' \
       'visit and house colors'
  task set_container_stage_weighted_points: :environment do
    stage_points = { 'Huevos' => 100, 'Larvas' => 1000, 'Pupas' => 1000 }
    stage_options = Option.joins(:question)
                          .where(questions: { resource_name: 'type_content_id' }, name_es: stage_points.keys)
                          .to_a
    found_names = stage_options.map(&:name_es).sort
    abort("Expected one option each for #{stage_points.keys.inspect}; found #{found_names.inspect}") unless
      found_names == stage_points.keys.sort

    ApplicationRecord.transaction do
      stage_options.each { |option| option.update!(weighted_points: stage_points.fetch(option.name_es)) }

      inspection_changes = Hash.new(0)
      visit_ids = Set.new
      Inspection.includes(:type_contents, :container_protections).find_each do |inspection|
        color = Services::RiskColorCalculator.inspection_color(
          has_water: inspection.has_water,
          type_content_ids: inspection.type_content_ids,
          container_protection_ids: inspection.container_protection_ids
        )
        next if inspection.color == color

        inspection_changes[[inspection.color, color]] += 1
        visit_ids << inspection.visit_id
        inspection.update!(color:)
      end

      visit_changes = Hash.new(0)
      house_changes = Hash.new(0)
      Visit.where(id: visit_ids.to_a).includes(:house).group_by(&:house).each do |house, visits|
        house.with_lock do
          previous_house_status = house.status
          visits.each do |visit|
            status = Services::RiskColorCalculator.visit_snapshot(visit)[:status]
            next if visit.status == status

            visit_changes[[visit.status, status]] += 1
            visit.update!(status:)
          end
          affected_dates = visits.map { |visit| Services::VisitStateReconciler.reporting_date(visit.visited_at) }
          Services::VisitStateReconciler.call!(house:, affected_dates:)
          house_changes[[previous_house_status, house.status]] += 1 unless house.status == previous_house_status
        end
      end

      puts "Containers recolored: #{inspection_changes.inspect}"
      puts "Visits recolored: #{visit_changes.inspect}"
      puts "Houses recolored: #{house_changes.inspect}"
    end
  end

  desc 'Give facilitador the permissions brigadista has and it lacks, and delete the unused ' \
       'visits_download_information permission'
  task backfill_facilitador_permissions: :environment do
    missing = [
      { name: 'create', resource: 'house_blocks' },
      { name: 'update', resource: 'house_blocks' },
      { name: 'orphan_houses', resource: 'houses' },
      { name: 'change_assignment', resource: 'users' },
      { name: 'stats', resource: 'wedges' }
    ]
    # Seeded databases still call this role team_leader.
    roles = Role.where(name: %w[facilitador team_leader]).to_a
    abort('No facilitador or team_leader role found') if roles.empty?

    ApplicationRecord.transaction do
      permissions = missing.map { |attrs| Permission.find_or_create_by!(attrs) }
      roles.each do |role|
        added = permissions.reject { |permission| role.permissions.exists?(permission.id) }
        role.permissions << added
        puts "#{role.name}: added #{added.map { |p| "#{p.resource}.#{p.name}" }.inspect}"
      end

      # No controller action has this name, so check_permissions! never reads it.
      unused = Permission.where(name: 'visits_download_information', resource: 'visits').to_a
      RolePermission.where(permission: unused).delete_all
      unused.each(&:destroy!)
      puts "visits.visits_download_information: deleted #{unused.size}"
    end
  end

  desc 'Leave each user account with only its highest role (admin > facilitador > brigadista). ' \
       'Run after backfill_facilitador_permissions'
  task keep_highest_role: :environment do
    account_ids = UserAccount.with_discarded.joins(:roles).group(:id).having('COUNT(roles.id) > 1').pluck(:id)
    accounts = UserAccount.with_discarded.where(id: account_ids).includes(roles: :permissions).order(:id).to_a

    unknown = accounts.flat_map(&:roles).map(&:name).uniq - Constants::Role::HIERARCHY
    abort("Roles outside the hierarchy: #{unknown.inspect}") if unknown.any?

    # Keeping one role must not take a permission away from anyone.
    gaps = accounts.flat_map do |account|
      kept = account.role
      (account.roles - [kept]).filter_map do |dropped|
        missing = dropped.permissions - kept.permissions
        "#{kept.name} lacks #{missing.map { |p| "#{p.resource}.#{p.name}" }} from #{dropped.name}" if missing.any?
      end
    end.uniq
    abort("Keeping only the highest role would remove permissions:\n#{gaps.join("\n")}") if gaps.any?

    ApplicationRecord.transaction do
      accounts.each do |account|
        before = account.roles.map(&:name).sort_by { |name| Constants::Role.rank(name) }
        kept = account.role
        account.roles = [kept]
        puts "#{account.id} #{account.username}: #{before.join('+')} -> #{kept.name}"
      end

      orphaned = ApplicationRecord.connection.delete(
        'DELETE FROM user_accounts_roles WHERE user_account_id NOT IN (SELECT id FROM user_accounts)'
      )
      puts "Role rows of deleted accounts removed: #{orphaned}"
    end
    puts "Accounts changed: #{accounts.size}"
  end

  desc 'Rebuild visit duplicate candidates for every house (same house, day and permission answer)'
  task rebuild_visit_duplicate_candidates: :environment do
    result = Services::VisitDuplicateCandidateRepairer.new.call
    abort("Rebuild completed with #{result[:failed]} failed houses") if result[:failed].positive?
  end
end
