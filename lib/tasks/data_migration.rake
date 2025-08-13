# frozen_string_literal: true

namespace :data_migration do
  desc 'Migrate "Pozos" option to "Tanques" and remove the old option'
  task migrate_pozos_to_tanques: :environment do
    puts 'Starting migration: migrate_pozos_to_tanques'
    puts "Environment: #{Rails.env}"

    # Find the question
    question = Question.find_by(question_text_es: '¿Qué tipo de envase encontraste?')

    unless question
      puts "ERROR: Question with text '¿Qué tipo de envase encontraste?' not found"
      return
    end

    puts "✓ Found question: #{question.question_text_es} (ID: #{question.id})"

    # Find the "Pozos" option
    pozos_option = question.options.find_by(name_es: 'Pozos')

    unless pozos_option
      puts "ERROR: Option 'Pozos' not found for this question"
      return
    end

    puts "✓ Found 'Pozos' option (ID: #{pozos_option.id}, resource_id: #{pozos_option.resource_id})"

    # Find the "Tanques" option
    tanques_option = question.options.find_by(name_es: 'Tanques')

    unless tanques_option
      puts "ERROR: Option 'Tanques' not found for this question"
      return
    end

    puts "✓ Found 'Tanques' option (ID: #{tanques_option.id}, resource_id: #{tanques_option.resource_id})"

    # Find the breeding site types
    pozos_bst = BreedingSiteType.find_by(name: 'Pozos')
    tanques_bst = BreedingSiteType.find_by(name: 'Tanques')

    unless pozos_bst
      puts "ERROR: BreedingSiteType 'Pozos' not found"
      return
    end

    unless tanques_bst
      puts "ERROR: BreedingSiteType 'Tanques' not found"
      return
    end

    puts "✓ Found BreedingSiteType 'Pozos' (ID: #{pozos_bst.id})"
    puts "✓ Found BreedingSiteType 'Tanques' (ID: #{tanques_bst.id})"

    # Count inspections that will be migrated
    inspections_to_migrate = Inspection.where(breeding_site_type_id: pozos_bst.id)
    inspection_count = inspections_to_migrate.count

    # Check for additional information records
    additional_info_count = pozos_bst.additional_information.count

    puts "\n📊 Migration Summary:"
    puts "  - Inspections to migrate: #{inspection_count}"
    puts "  - Additional information records: #{additional_info_count}"
    puts "  - From BreedingSiteType: 'Pozos' (ID: #{pozos_bst.id})"
    puts "  - To BreedingSiteType: 'Tanques' (ID: #{tanques_bst.id})"

    if inspection_count.zero?
      puts "\n⚠️  No inspections found to migrate"
    else
      # Migrate inspections
      puts "\n🔄 Migrating inspections..."
      updated_count = inspections_to_migrate.update_all(breeding_site_type_id: tanques_bst.id)
      puts "✓ Successfully migrated #{updated_count} inspections"
    end

    # Handle additional information records
    if additional_info_count.positive?
      puts "\n🔄 Migrating additional information records..."
      pozos_bst.additional_information.update_all(breeding_site_type_id: tanques_bst.id)
      puts "✓ Successfully migrated #{additional_info_count} additional information records"
    end

    # Safety check: verify no other references to pozos_bst
    remaining_inspections = Inspection.where(breeding_site_type_id: pozos_bst.id).count
    remaining_additional_info = pozos_bst.additional_information.count

    if remaining_inspections.positive? || remaining_additional_info.positive?
      puts "\n❌ ERROR: Still found references to 'Pozos' breeding site type:"
      puts "  - Remaining inspections: #{remaining_inspections}"
      puts "  - Remaining additional info: #{remaining_additional_info}"
      puts 'Migration aborted for safety.'
      return
    end

    puts "\n✅ Safety check passed - no remaining references to 'Pozos' breeding site type"

    # Remove the "Pozos" option
    puts "\n🗑️  Removing 'Pozos' option..."
    pozos_option.destroy!
    puts "✓ Removed 'Pozos' option (ID: #{pozos_option.id})"

    # Remove the "Pozos" breeding site type
    puts "\n🗑️  Removing 'Pozos' breeding site type..."
    pozos_bst.destroy!
    puts "✓ Removed 'Pozos' breeding site type (ID: #{pozos_bst.id})"

    puts "\n✅ Migration completed successfully!"
    puts "  - #{inspection_count} inspections migrated from 'Pozos' to 'Tanques'"
    puts "  - #{additional_info_count} additional information records migrated"
    puts "  - 'Pozos' option and breeding site type removed"
  end

  desc 'Updates the containers list to the lastest version that they have on paper'
  task update_container_type_list: :environment do
    puts 'Starting migration: update_container_type_list'
    puts "Environment: #{Rails.env}"

    updated_list = [
      {
        current_label: 'Uso doméstico: ollas, sartenes, vasos, baldes',
        option: {
          name_es: '1. Uso doméstico: ollas, sartenes, vasos, baldes',
          name_en: '1. Domestic use: pots, pans, glasses, buckets',
          name_pt: '1. Uso doméstico: panelas, frigideiras, copos, baldes',
          group_es: 'No permanentes',
          group_en: 'Non-permanent',
          group_pt: 'Não permanentes',
          required: false,
          disable_other_options: false,
          position: 1
        },
        breeding_site_type: {
          name: '1. Uso doméstico: ollas, sartenes, vasos, baldes',
          name_en: '1. Domestic use: pots, pans, glasses, buckets',
          name_pt: '1. Uso doméstico: panelas, frigideiras, copos, baldes',
          container_type: 'non-permanent'
        }
      },
      {
        current_label: 'Otros',
        option: {
          name_es: '2. Otros: juguetes, latas de comida o pintura, plásticos',
          name_en: '2. Others: toys, food or paint cans, plastics',
          name_pt: '2. Outros: brinquedos, latas de comida ou tinta, plásticos',
          group_es: 'No permanentes',
          group_en: 'Non-permanent',
          group_pt: 'Não permanentes',
          required: false,
          disable_other_options: false,
          position: 2
        },
        breeding_site_type: {
          name: '2. Otros: juguetes, latas de comida o pintura, plásticos',
          name_en: '2. Others: toys, food or paint cans, plastics',
          name_pt: '2. Outros: brinquedos, latas de comida ou tinta, plásticos',
          container_type: 'non-permanent'
        }
      },
      {
        current_label: 'Llantas',
        option: {
          name_es: '3. Llantas',
          name_en: '3. Tires',
          name_pt: '3. Pneus',
          group_es: 'No permanentes',
          group_en: 'Non-permanent',
          group_pt: 'Não permanentes',
          required: false,
          disable_other_options: false,
          position: 3
        },
        breeding_site_type: {
          name: '3. Llantas',
          name_en: '3. Tires',
          name_pt: '3. Pneus',
          container_type: 'non-permanent'
        }
      },
      {
        current_label: 'Plantas, frutas o verduras',
        option: {
          name_es: '4. Plantas, frutas, verduras',
          name_en: '4. Plants, fruits, vegetables',
          name_pt: '4. Plantas, frutas, verduras',
          group_es: 'No permanentes',
          group_en: 'Non-permanent',
          group_pt: 'Não permanentes',
          required: false,
          disable_other_options: false,
          position: 4
        },
        breeding_site_type: {
          name: '4. Plantas, frutas, verduras',
          name_en: '4. Plants, fruits, vegetables',
          name_pt: '4. Plantas, frutas, verduras',
          container_type: 'non-permanent'
        }
      },
      {
        current_label: 'Maceteros o floreros',
        option: {
          name_es: '5. Maceteros y floreros',
          name_en: '5. Flower pots and vases',
          name_pt: '5. Vasos e vasos de flores',
          group_es: 'No permanentes',
          group_en: 'Non-permanent',
          group_pt: 'Não permanentes',
          required: false,
          disable_other_options: false,
          position: 5
        },
        breeding_site_type: {
          name: '5. Maceteros y floreros',
          name_en: '5. Flower pots and vases',
          name_pt: '5. Vasos e vasos de flores',
          container_type: 'non-permanent'
        }
      },
      {
        current_label: 'Criaderos, bebederos o acuarios',
        option: {
          name_es: '6. Bebederos',
          name_en: '6. Drinking fountains',
          name_pt: '6. Bebedouros',
          group_es: 'No permanentes',
          group_en: 'Non-permanent',
          group_pt: 'Não permanentes',
          required: false,
          disable_other_options: false,
          position: 6
        },
        breeding_site_type: {
          name: '6. Bebederos',
          name_en: '6. Drinking fountains',
          name_pt: '6. Bebedouros',
          container_type: 'non-permanent'
        }
      },
      {
        current_label: 'Tanques',
        option: {
          name_es: '7. Tanques',
          name_en: '7. Tanks',
          name_pt: '7. Tanques',
          group_es: 'Permanentes',
          group_en: 'Permanent',
          group_pt: 'Permanentes',
          required: false,
          disable_other_options: false,
          position: 7
        },
        breeding_site_type: {
          name: '7. Tanques',
          name_en: '7. Tanks',
          name_pt: '7. Tanques',
          container_type: 'permanent'
        }
      },
      {
        current_label: 'Bidones o cilindros (metal, plástico)',
        option: {
          name_es: '8. Bidones / Cilindros',
          name_en: '8. Bins / Cylinders',
          name_pt: '8. Bidons / Cilindros',
          group_es: 'Permanentes',
          group_en: 'Permanent',
          group_pt: 'Permanentes',
          required: false,
          disable_other_options: false,
          position: 8
        },
        breeding_site_type: {
          name: '8. Bidones / Cilindros',
          name_en: '8. Bins / Cylinders',
          name_pt: '8. Bidons / Cilindros',
          container_type: 'permanent'
        }
      },
      {
        current_label: 'Estructura de la casa',
        option: {
          name_es: '9. Estructuras de casa, pisos, sifones',
          name_en: '9. House structures, floors, siphons',
          name_pt: '9. Estruturas de casas, pisos, sifões',
          group_es: 'Permanentes',
          group_en: 'Permanent',
          group_pt: 'Permanentes',
          required: false,
          disable_other_options: false,
          position: 9
        },
        breeding_site_type: {
          name: '9. Estructuras de casa, pisos, sifones',
          name_en: '9. House structures, floors, siphons',
          name_pt: '9. Estruturas de casas, pisos, sifões',
          container_type: 'permanent'
        }
      },
      {
        current_label: 'Sumidero',
        option: {
          name_es: '10. Sumideros',
          name_en: '10. Sinks',
          name_pt: '10. Pias',
          group_es: 'Permanentes',
          group_en: 'Permanent',
          group_pt: 'Permanentes',
          required: false,
          disable_other_options: false,
          position: 10
        },
        breeding_site_type: {
          name: '10. Sumideros',
          name_en: '10. Sinks',
          name_pt: '10. Pias',
          container_type: 'permanent'
        }
      }
    ]

    question = Question.find_by(question_text_es: '¿Qué tipo de envase encontraste?')

    if question.nil?
      puts "❌ Question not found: '¿Qué tipo de envase encontraste?'"
      return
    end

    puts "Found question: #{question.question_text_es}"
    puts "Total options to process: #{updated_list.length}"

    updated_count = 0
    created_count = 0
    breeding_site_updated_count = 0
    breeding_site_created_count = 0

    updated_list.each do |item|
      # Find the option by current label (Spanish name)
      option = question.options.find_by(name_es: item[:current_label])

      if option.nil?
        puts "🆕 Creating new option: #{item[:current_label]}"

        # Create new breeding site type first
        breeding_site_type = nil
        begin
          breeding_site_type = BreedingSiteType.create!(item[:breeding_site_type])
          breeding_site_created_count += 1
          puts "  ✅ Created breeding site type: #{breeding_site_type.name}"
        rescue StandardError => error
          puts "  ❌ Failed to create breeding site type: #{error.message}"
          next
        end

        # Create new option with the breeding site type's ID
        begin
          option_data = item[:option].merge(resource_id: breeding_site_type.id)
          option = question.options.create!(option_data)
          created_count += 1
          puts "  ✅ Created option: #{option.name_es} with resource_id: #{option.resource_id}"
        rescue StandardError => error
          puts "  ❌ Failed to create option: #{error.message}"
          # Clean up the breeding site type if option creation fails
          breeding_site_type.destroy if breeding_site_type
          breeding_site_created_count -= 1
          next
        end
      else
        puts "Processing existing option: #{item[:current_label]}"

        # Update the option
        begin
          option.update!(item[:option])
          updated_count += 1
          puts "  ✅ Updated option: #{option.name_es}"
        rescue StandardError => error
          puts "  ❌ Failed to update option: #{error.message}"
          next
        end

        # Update the corresponding breeding site type if resource_id exists
        if option.resource_id.present?
          breeding_site_type = BreedingSiteType.find_by(id: option.resource_id)

          if breeding_site_type
            begin
              breeding_site_type.update!(item[:breeding_site_type])
              breeding_site_updated_count += 1
              puts "  ✅ Updated breeding site type: #{breeding_site_type.name}"
            rescue StandardError => error
              puts "  ❌ Failed to update breeding site type: #{error.message}"
            end
          else
            puts "  ⚠️  Breeding site type not found for resource_id: #{option.resource_id}"
          end
        else
          puts '  ℹ️  No resource_id found for this option'
        end
      end
    end

    puts "\n✅ Migration completed successfully!"
    puts "  - #{updated_count} options updated"
    puts "  - #{created_count} options created"
    puts "  - #{breeding_site_updated_count} breeding site types updated"
    puts "  - #{breeding_site_created_count} breeding site types created"
    puts "  - Total processed: #{updated_list.length}"
  end
end
