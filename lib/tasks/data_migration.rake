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
       'visit and house colors (dry-run by default; use APPLY=true to persist)'
  task set_container_stage_weighted_points: :environment do
    apply = ENV.fetch('APPLY', 'false') == 'true'
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
      next if apply

      puts 'Dry run only. Set APPLY=true to persist.'
      raise ActiveRecord::Rollback
    end
  end
end
