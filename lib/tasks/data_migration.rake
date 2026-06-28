# frozen_string_literal: true

namespace :data_migration do
  desc 'Migrate legacy risk colors to green/yellow/red, recalculate statuses, and verify data'
  task finalize_risk_colors: :environment do
    legacy_map = {
      '0' => Constants::RiskColor::GREEN,
      '1' => Constants::RiskColor::YELLOW,
      '2' => Constants::RiskColor::RED,
      'verde' => Constants::RiskColor::GREEN,
      'amarillo' => Constants::RiskColor::YELLOW,
      'rojo' => Constants::RiskColor::RED,
      'green' => Constants::RiskColor::GREEN,
      'yellow' => Constants::RiskColor::YELLOW,
      'red' => Constants::RiskColor::RED
    }.freeze

    model_attributes = {
      Inspection => :color,
      Visit => :status,
      House => :status,
      HouseStatus => :status
    }.freeze

    raw_value = ->(record, attribute) { record.read_attribute_before_type_cast(attribute) }
    canonical_value = lambda do |value|
      normalized_value = value.to_s.strip.downcase

      legacy_map.fetch(normalized_value, normalized_value)
    end

    puts 'Migrating legacy risk colors to canonical values...'

    model_attributes.each do |model, attribute|
      puts "Normalizing #{model.name}##{attribute}..."
      model.find_each do |record|
        current = raw_value.call(record, attribute)
        canonical = canonical_value.call(current)
        next if current.blank? || current == canonical

        record.update_columns(attribute => canonical, updated_at: Time.current)
      end
    end

    puts 'Normalizing options.status_color...'
    Option.where.not(status_color: nil).find_each do |option|
      canonical = canonical_value.call(option.status_color)
      next if option.status_color == canonical

      option.update_columns(status_color: canonical, updated_at: Time.current)
    end

    puts 'Recalculating inspection, visit, and house colors...'

    Inspection.includes(:type_contents, :container_protections).find_each do |inspection|
      color = Services::RiskColorCalculator.inspection_color(
        has_water: inspection.has_water,
        type_content_ids: inspection.type_contents.pluck(:id),
        container_protection_ids: inspection.container_protections.pluck(:id)
      )
      next if inspection.color == color

      inspection.update_columns(color:, updated_at: Time.current)
    end

    Visit.includes(:inspections, :visit_permission_option).find_each do |visit|
      status = Services::RiskColorCalculator.visit_status(visit)
      next if visit.status == status

      visit.update_columns(status:, updated_at: Time.current)
    end

    processed = {}
    Visit.includes(:inspections, :visit_permission_option, house: :house_blocks)
         .order(visited_at: :desc, created_at: :desc)
         .find_each do |visit|
      key = [visit.house_id, visit.visited_at&.to_date]
      next if processed[key]

      processed[key] = true

      house = visit.house
      next unless house && visit.visited_at

      counts = Services::RiskColorCalculator.inspection_counts(visit.inspections.group(:color).count)
      house_status = HouseStatus.find_or_initialize_by(house_id: house.id, date: visit.visited_at.to_date)
      house_status.assign_attributes(
        date: visit.visited_at,
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
        house_id: house.id,
        status: Services::RiskColorCalculator.visit_status(visit)
      )
      house_status.save!
    end

    House.find_each do |house|
      latest_house_status = HouseStatus.where(house_id: house.id).order(date: :desc, created_at: :desc).first
      next unless latest_house_status

      house.update!(
        infected_containers: latest_house_status.infected_containers,
        non_infected_containers: latest_house_status.non_infected_containers,
        potential_containers: latest_house_status.potential_containers,
        last_visit: latest_house_status.last_visit,
        status: latest_house_status.status,
        tariki_status: house.tariki?(latest_house_status.status)
      )
    end

    invalid = []
    model_attributes.each do |model, attribute|
      table = model.table_name
      column = "#{table}.#{attribute}"
      invalid_scope = if model == House && attribute == :status
                        model.where("#{column} IS NOT NULL AND #{column} NOT IN (?)", Constants::RiskColor::ALL)
                      else
                        model.where("#{column} IS NULL OR #{column} NOT IN (?)", Constants::RiskColor::ALL)
                      end

      invalid_scope.find_each do |record|
        invalid << "#{model.name}##{record.id}.#{attribute}=#{raw_value.call(record, attribute).inspect}"
      end
    end
    Option.where('status_color IS NOT NULL AND status_color NOT IN (?)', Constants::RiskColor::ALL).find_each do |option|
      invalid << "Option##{option.id}.status_color=#{option.status_color.inspect}"
    end

    if invalid.any?
      raise "Risk color migration incomplete (#{invalid.size} invalid values):\n#{invalid.first(20).join("\n")}"
    end

    puts 'Done.'
  end

  desc 'Latest changes in the house status coloring algorithm'
  task house_color_changes: :environment do
    Option.find_by!(name_es: 'Uso diario del agua').update!(name_es: 'Recambio completo de agua diario')
    Option.find_by!(name_es: 'Huevos').update!(status_color: Constants::RiskColor::YELLOW)
    Option.find_by!(name_es: 'Larvas').update!(weighted_points: 10)

    puts 'Recalculating inspection, visit, and house colors...'

    Inspection.includes(:type_contents, :container_protections).find_each do |inspection|
      color = Services::RiskColorCalculator.inspection_color(
        has_water: inspection.has_water,
        type_content_ids: inspection.type_contents.pluck(:id),
        container_protection_ids: inspection.container_protections.pluck(:id)
      )
      next if inspection.color == color

      inspection.update_columns(color:, updated_at: Time.current)
    end

    Visit.includes(:inspections, :visit_permission_option).find_each do |visit|
      status = Services::RiskColorCalculator.visit_status(visit)
      next if visit.status == status

      visit.update_columns(status:, updated_at: Time.current)
    end

    processed = {}
    Visit.includes(:inspections, :visit_permission_option, house: :house_blocks)
         .order(visited_at: :desc, created_at: :desc)
         .find_each do |visit|
      key = [visit.house_id, visit.visited_at&.to_date]
      next if processed[key]

      processed[key] = true

      house = visit.house
      next unless house && visit.visited_at

      counts = Services::RiskColorCalculator.inspection_counts(visit.inspections.group(:color).count)
      house_status = HouseStatus.find_or_initialize_by(house_id: house.id, date: visit.visited_at.to_date)
      house_status.assign_attributes(
        date: visit.visited_at,
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
        house_id: house.id,
        status: Services::RiskColorCalculator.visit_status(visit)
      )
      house_status.save!
    end

    House.find_each do |house|
      latest_house_status = HouseStatus.where(house_id: house.id).order(date: :desc, created_at: :desc).first
      next unless latest_house_status

      house.update!(
        infected_containers: latest_house_status.infected_containers,
        non_infected_containers: latest_house_status.non_infected_containers,
        potential_containers: latest_house_status.potential_containers,
        last_visit: latest_house_status.last_visit,
        status: latest_house_status.status,
        tariki_status: house.tariki?(latest_house_status.status)
      )
    end

    puts 'Done.'
  end
end
