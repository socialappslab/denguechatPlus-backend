# frozen_string_literal: true

require 'roo'
require 'stringio'

module Api
  module V1
    module Visits
      module Operations
        class BulkUpload < ApplicationOperation # rubocop:disable Metrics/ClassLength
          include Dry::Transaction

          VISITS_SHEET_NAME = 'Visitas'
          CONTAINERS_SHEET_NAME = 'Envases'

          module VisitsHeaderQuestion
            SITE_CODE = 'Código de sitio'
            DATE = 'Fecha'
            BRIGADIST = 'Brigadista'
            START_SIDE = '¿Dónde comienza la visita?'
            VISIT_PERMISSION = '¿Me dieron permiso para visitar la casa?'
            OTHER_VISIT_PERMISSION = 'Otra explicación'
            HOSTS = '¿Quién te acompaña hoy en esta visita?'
            FAMILY_EDUCATION_TOPICS = '¿Qué información compartiste?'
            NOTES = 'Agregar comentarios sobre la visita'
          end

          # NOTE: order of the options is important
          module VisitsHeaderMultiselectOptions
            HOSTS = ['Adulto mayor', 'Adulto hombre', 'Adulto mujer', 'Joven hombre', 'Joven mujer', 'Niños\as'].freeze
            FAMILY_EDUCATION_TOPICS = [
              'Explicación de larvas y pupas',
              'Explicación sobre cómo se reproduce el zancudo',
              'Explicación sobre cómo manejar los envases',
              'Explicación sobre la enfermedad del dengue',
              'Otro tema importante'
            ].freeze
          end

          module ContainersHeaderQuestion
            SITE_CODE = 'Código de sitio'
            LOCATION_SIDE = 'Ubicación del contendor'
            BREEDING_SITE_TYPE = '¿Qué tipo de envase encontraste?'
            WATER_SOURCE_TYPE = '¿De dónde proviene el agua?'
            CONTAINER_PROTECTION = '¿El envase está protegido?'
            WAS_CHEMICALLY_TREATED = 'Pregunte si en los últimos 30 días: ¿fue el envase tratado por el Ministerio de Salud con piriproxifeno o abate?'
            TYPE_CONTENT = 'En este envase hay..'
            ELIMINATION_METHOD_TYPE = '¿Qué acción se realizó con el envase?'
          end

          # NOTE: order of the options is important
          module ContainersHeaderMultiselectOptions
            WATER_SOURCE_TYPE = [
              'Del grifo o de otro envase',
              'Agua activamente recogida. Ejemplo: canaleta, gotera, techo.',
              'Agua pasivamente recogida. Ejemplo: la lluvia lo llenó.',
              'Otro (tratamiento manual)'
            ].freeze
            CONTAINER_PROTECTION = [
              'Si, tiene tapa y está bien cerrado',
              'Si, tiene tapa pero no está bien cerrado',
              'Está bajo techo',
              'No tiene tapa',
              'Uso diario del agua',
              'Otro tipo de protección'
            ].freeze
            TYPE_CONTENT = ['Huevos', 'Pupas', 'Larvas', 'Nada', 'No pude revisar el envase'].freeze
            ELIMINATION_METHOD_TYPE = [
              'Tapamos el envase',
              'Vaciamos el agua',
              'Trasladamos el envase a un techo o a un lugar cerrado',
              'Tiramos el envase',
              'Limpiamos el envase',
              'No fue necesario tomar ninguna acción',
              'No se tomó ninguna acción',
              'Otro'
            ].freeze
          end

          VISITS_HEADER_STRUCTURE = [
            # First row
            [
              VisitsHeaderQuestion::SITE_CODE,
              VisitsHeaderQuestion::DATE,
              VisitsHeaderQuestion::BRIGADIST,
              VisitsHeaderQuestion::START_SIDE,
              VisitsHeaderQuestion::VISIT_PERMISSION,
              VisitsHeaderQuestion::OTHER_VISIT_PERMISSION,
              VisitsHeaderQuestion::HOSTS,
              nil,
              nil,
              nil,
              nil,
              nil,
              VisitsHeaderQuestion::FAMILY_EDUCATION_TOPICS,
              nil,
              nil,
              nil,
              nil,
              VisitsHeaderQuestion::NOTES
            ],

            # Second row
            [
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              VisitsHeaderMultiselectOptions::HOSTS[0],
              VisitsHeaderMultiselectOptions::HOSTS[1],
              VisitsHeaderMultiselectOptions::HOSTS[2],
              VisitsHeaderMultiselectOptions::HOSTS[3],
              VisitsHeaderMultiselectOptions::HOSTS[4],
              VisitsHeaderMultiselectOptions::HOSTS[5],
              VisitsHeaderMultiselectOptions::FAMILY_EDUCATION_TOPICS[0],
              VisitsHeaderMultiselectOptions::FAMILY_EDUCATION_TOPICS[1],
              VisitsHeaderMultiselectOptions::FAMILY_EDUCATION_TOPICS[2],
              VisitsHeaderMultiselectOptions::FAMILY_EDUCATION_TOPICS[3],
              VisitsHeaderMultiselectOptions::FAMILY_EDUCATION_TOPICS[4],
              nil
            ]
          ].freeze

          CONTAINERS_HEADER_STRUCTURE = [
            # First row
            [
              ContainersHeaderQuestion::SITE_CODE,
              ContainersHeaderQuestion::LOCATION_SIDE,
              ContainersHeaderQuestion::BREEDING_SITE_TYPE,
              ContainersHeaderQuestion::WATER_SOURCE_TYPE,
              nil,
              nil,
              nil,
              ContainersHeaderQuestion::CONTAINER_PROTECTION,
              nil,
              nil,
              nil,
              nil,
              nil,
              ContainersHeaderQuestion::WAS_CHEMICALLY_TREATED,
              ContainersHeaderQuestion::TYPE_CONTENT,
              nil,
              nil,
              nil,
              nil,
              ContainersHeaderQuestion::ELIMINATION_METHOD_TYPE,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil
            ],

            # Second row
            [
              nil,
              nil,
              nil,
              ContainersHeaderMultiselectOptions::WATER_SOURCE_TYPE[0],
              ContainersHeaderMultiselectOptions::WATER_SOURCE_TYPE[1],
              ContainersHeaderMultiselectOptions::WATER_SOURCE_TYPE[2],
              ContainersHeaderMultiselectOptions::WATER_SOURCE_TYPE[3],
              ContainersHeaderMultiselectOptions::CONTAINER_PROTECTION[0],
              ContainersHeaderMultiselectOptions::CONTAINER_PROTECTION[1],
              ContainersHeaderMultiselectOptions::CONTAINER_PROTECTION[2],
              ContainersHeaderMultiselectOptions::CONTAINER_PROTECTION[3],
              ContainersHeaderMultiselectOptions::CONTAINER_PROTECTION[4],
              ContainersHeaderMultiselectOptions::CONTAINER_PROTECTION[5],
              nil,
              ContainersHeaderMultiselectOptions::TYPE_CONTENT[0],
              ContainersHeaderMultiselectOptions::TYPE_CONTENT[1],
              ContainersHeaderMultiselectOptions::TYPE_CONTENT[2],
              ContainersHeaderMultiselectOptions::TYPE_CONTENT[3],
              ContainersHeaderMultiselectOptions::TYPE_CONTENT[4],
              ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE[0],
              ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE[1],
              ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE[2],
              ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE[3],
              ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE[4],
              ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE[5],
              ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE[6],
              ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE[7]
            ]
          ].freeze

          # NOTE: same as the second row of VISITS_HEADER_STRUCTURE but with the options grouped
          VISIT_OPTIONS_HEADER_STRUCTURE = [
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            VisitsHeaderMultiselectOptions::HOSTS,
            VisitsHeaderMultiselectOptions::FAMILY_EDUCATION_TOPICS,
            nil
          ].freeze

          CONTAINER_OPTIONS_HEADER_STRUCTURE = [
            nil,
            nil,
            nil,
            ContainersHeaderMultiselectOptions::WATER_SOURCE_TYPE,
            ContainersHeaderMultiselectOptions::CONTAINER_PROTECTION,
            nil,
            ContainersHeaderMultiselectOptions::TYPE_CONTENT,
            ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE
          ].freeze

          QUESTIONS_THAT_WE_DONT_WANT_TO_VALIDATE = {
            visits: [
              VisitsHeaderQuestion::SITE_CODE,
              VisitsHeaderQuestion::DATE,
              VisitsHeaderQuestion::BRIGADIST,
              VisitsHeaderQuestion::OTHER_VISIT_PERMISSION,
              VisitsHeaderQuestion::NOTES
            ],
            containers: [
              ContainersHeaderQuestion::SITE_CODE,
              ContainersHeaderQuestion::LOCATION_SIDE
            ]
          }.freeze

          step :validate_contract
          step :open_workbook
          step :load_questionnaire
          step :parse
          step :validate_sheets_and_rows
          step :validate_rows
          step :extract_values
          step :create_visits

          def validate_contract(input)
            result = Api::V1::Visits::Contracts::BulkUpload.new.call(input[:params])

            if result.failure?
              errors = result.errors.map do |e|
                ErrorFormater.new_error(field: e.path.last || :file, msg: e.text)
              end.flatten
              return Failure({ errors:, type: :invalid })
            end

            Success(input.merge(contract: result))
          end

          def open_workbook(input)
            file = input[:params][:file]
            io = file.respond_to?(:tempfile) ? file.tempfile.path : file.path
            Success(input.merge(xlsx_path: io, original_file: file))
          end

          def load_questionnaire(input)
            questionnaire = Questionnaire.find_by!(current_form: true)
            Success(input.merge(questionnaire:))
          end

          def parse(input)
            xlsx = Roo::Excelx.new(input[:xlsx_path])

            Success(input.merge(xlsx:))
          end

          def validate_sheets_and_rows(input) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            xlsx = input[:xlsx]
            questionnaire = input[:questionnaire]
            questions = questionnaire.questions

            errors = []

            begin
              visits_sheet = xlsx.sheet_for(VISITS_SHEET_NAME)
            rescue RangeError
              errors += ErrorFormater.new_error(
                field: :base,
                msg: "Hoja \"#{VISITS_SHEET_NAME}\" no existe",
                custom_predicate: :not_found?
              )
              return Failure({ errors:, type: :invalid })
            end

            visits_questions_headers = visits_sheet.row(1)
            visits_options_headers = visits_sheet.row(2)
            visits_headers = [visits_questions_headers, visits_options_headers]

            unless visits_headers == VISITS_HEADER_STRUCTURE
              errors += ErrorFormater.new_error(
                field: :base,
                msg: "#{VISITS_SHEET_NAME} - Encabezados son inválidos. Revise si cuenta con la última versión del archivo",
                custom_predicate: :invalid_format?
              )
            end

            begin
              containers_sheet = xlsx.sheet_for(CONTAINERS_SHEET_NAME)
            rescue RangeError
              errors += ErrorFormater.new_error(
                field: :base,
                msg: "Hoja \"#{CONTAINERS_SHEET_NAME}\" no existe",
                custom_predicate: :not_found?
              )
              return Failure({ errors:, type: :invalid })
            end

            containers_questions_headers = containers_sheet.row(1)
            containers_options_headers = containers_sheet.row(2)
            containers_headers = [containers_questions_headers, containers_options_headers]

            unless containers_headers == CONTAINERS_HEADER_STRUCTURE
              errors += ErrorFormater.new_error(
                field: :base,
                msg: "#{CONTAINERS_SHEET_NAME} - Encabezados son inválidos. Revise si cuenta con la última versión del archivo",
                custom_predicate: :invalid_format?
              )
            end

            visits_questions_headers.compact_blank.each_with_index do |question_header, index|
              next if QUESTIONS_THAT_WE_DONT_WANT_TO_VALIDATE[:visits].include?(question_header)

              question = questions.find_by(question_text_es: question_header)
              if question.present?
                options = VISIT_OPTIONS_HEADER_STRUCTURE[index]
                next if options.blank?

                options.each do |option_header|
                  next if question.options.exists?(name_es: option_header)

                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{VISITS_SHEET_NAME} - Encabezado (opción) \"#{option_header}\" es inválido. Revise si cuenta con la última versión del archivo",
                    custom_predicate: :invalid_format?
                  )

                  next
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{VISITS_SHEET_NAME} - Encabezado (pregunta) \"#{question_header}\" es inválido. Revise si cuenta con la última versión del archivo",
                  custom_predicate: :invalid_format?
                )
              end
            end

            containers_questions_headers.compact_blank.each_with_index do |question_header, index|
              next if QUESTIONS_THAT_WE_DONT_WANT_TO_VALIDATE[:containers].include?(question_header)

              question = questions.find_by(question_text_es: question_header)
              if question.present?
                options = CONTAINER_OPTIONS_HEADER_STRUCTURE[index]
                next if options.blank?

                options.each do |option_header|
                  next if question.options.exists?(name_es: option_header)

                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Encabezado (opción) \"#{option_header}\" es inválido. Revise si cuenta con la última versión del archivo",
                    custom_predicate: :invalid_format?
                  )

                  next
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{CONTAINERS_SHEET_NAME} - Encabezado (pregunta) \"#{question_header}\" es inválido. Revise si cuenta con la última versión del archivo",
                  custom_predicate: :invalid_format?
                )
              end
            end

            return Failure({ errors:, type: :invalid }) if errors.any?

            Success(
              input.merge(
                sheets: [visits_sheet, containers_sheet],
                headers: [visits_headers, containers_headers]
              )
            )
          end

          def validate_rows(input) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
            visits_sheet, containers_sheet = input[:sheets]
            visits_headers, containers_headers = input[:headers]
            header_offsets = { visits: visits_headers.size, containers: containers_headers.size }
            questionnaire = input[:questionnaire]
            questions = questionnaire.questions

            errors = []

            visits_rows = get_rows(visits_sheet, header_offsets[:visits])
            containers_rows = get_rows(containers_sheet, header_offsets[:containers])

            if visits_rows.empty? && containers_rows.empty?
              errors += ErrorFormater.new_error(
                field: :base,
                msg: 'El archivo subido tiene una estructura válida pero no tiene datos para procesar',
                custom_predicate: :empty?
              )
            end

            start_side_options = questions.find_by!(question_text_es: VisitsHeaderQuestion::START_SIDE).options.pluck(:name_es)

            visit_permission_options_raw = questions.find_by!(question_text_es: VisitsHeaderQuestion::VISIT_PERMISSION).options
            visit_permission_options = visit_permission_options_raw.pluck(:name_es)
            visit_permission_other_option = visit_permission_options_raw.find_by!(type_option: 'textArea').name_es

            structured_visits_rows = visits_rows.map do |row|
              {
                site_code: row[0],
                date: row[1],
                brigadist: row[2],
                start_side: row[3],
                visit_permission: row[4..5],
                hosts: row[6..11],
                family_education_topics: row[12..16],
                notes: row[17]
              }
            end

            structured_visits_rows.each_with_index do |row, index| # rubocop:disable Metrics/BlockLength
              row_number = header_offsets[:visits] + 1 + index

              if row[:site_code].present?
                if row[:site_code].is_a?(String)
                  house = House.find_by(reference_code: row[:site_code])
                  if house.nil?
                    errors += ErrorFormater.new_error(
                      field: :base,
                      msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::SITE_CODE} \"#{row[:site_code]}\" no existe",
                      custom_predicate: :not_found?
                    )
                  end
                else
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::SITE_CODE} no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::SITE_CODE} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:date].present?
                unless row[:date].is_a?(Date)
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::DATE} no tiene una fecha válida",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::DATE} es requerida",
                  custom_predicate: :blank?
                )
              end

              if row[:brigadist].present?
                if row[:brigadist].is_a?(String)
                  user = UserAccount.find_by(username: row[:brigadist])
                  if user.nil?
                    errors += ErrorFormater.new_error(
                      field: :base,
                      msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::BRIGADIST} \"#{row[:brigadist]}\" no existe",
                      custom_predicate: :not_found?
                    )
                  end
                else
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::BRIGADIST} no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::BRIGADIST} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:start_side].present?
                if row[:start_side].is_a?(String)
                  unless start_side_options.include?(row[:start_side])
                    errors += ErrorFormater.new_error(
                      field: :base,
                      msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::START_SIDE} no tiene una opción válida",
                      custom_predicate: :not_found?
                    )
                  end
                else
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::START_SIDE} no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::START_SIDE} es requerido",
                  custom_predicate: :blank?
                )
              end

              visit_permission, other_visit_permission = row[:visit_permission]
              if visit_permission.present?
                if visit_permission.is_a?(String)
                  unless visit_permission_options.include?(visit_permission)
                    errors += ErrorFormater.new_error(
                      field: :base,
                      msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::VISIT_PERMISSION} no tiene una opción válida",
                      custom_predicate: :not_found?
                    )
                  end

                  if visit_permission == visit_permission_other_option && other_visit_permission.blank?
                    errors += ErrorFormater.new_error(
                      field: :base,
                      msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::OTHER_VISIT_PERMISSION} es requerido cuando #{VisitsHeaderQuestion::VISIT_PERMISSION} tiene la opción \"#{VisitsHeaderQuestion::OTHER_VISIT_PERMISSION}\" marcada",
                      custom_predicate: :blank?
                    )
                  end
                else
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::VISIT_PERMISSION} no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::VISIT_PERMISSION} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:hosts].compact_blank.present?
                unless row[:hosts].all? { |item| boolean?(item) }
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::HOSTS} tiene valores que no son booleanos",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::HOSTS} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:family_education_topics].compact_blank.present?
                *rest, last = row[:family_education_topics]
                unless rest.all? { |item| boolean?(item) }
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::FAMILY_EDUCATION_TOPICS} tiene valores que no son booleanos",
                    custom_predicate: :invalid_format?
                  )
                end
                if last.present? && !last.is_a?(String)
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::FAMILY_EDUCATION_TOPICS} último valor no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              end

              if row[:notes].present? && !row[:notes].is_a?(String) # rubocop:disable Style/Next
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{VISITS_SHEET_NAME} - Fila #{row_number}: #{VisitsHeaderQuestion::NOTES} no es una cadena de texto",
                  custom_predicate: :invalid_format?
                )
              end
            end

            breeding_site_type_options = questions.find_by!(question_text_es: ContainersHeaderQuestion::BREEDING_SITE_TYPE).options.pluck(:name_es)
            was_chemically_treated_options = questions.find_by!(question_text_es: ContainersHeaderQuestion::WAS_CHEMICALLY_TREATED).options.pluck(:name_es)

            structured_containers_rows = containers_rows.map do |row|
              {
                site_code: row[0],
                location_side: row[1],
                breeding_site_type: row[2],
                water_source_type: row[3..6],
                container_protection: row[7..12],
                was_chemically_treated: row[13],
                type_content: row[14..18],
                elimination_method_type: row[19..26]
              }
            end

            structured_containers_rows.each_with_index do |row, index| # rubocop:disable Metrics/BlockLength
              row_number = header_offsets[:containers] + 1 + index

              if row[:site_code].present?
                if row[:site_code].is_a?(String)
                  house = structured_visits_rows.find { |visit| visit[:site_code] == row[:site_code] }
                  if house.nil?
                    errors += ErrorFormater.new_error(
                      field: :base,
                      msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::SITE_CODE} \"#{row[:site_code]}\" no existe en #{VISITS_SHEET_NAME}",
                      custom_predicate: :not_found?
                    )
                  end
                else
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::SITE_CODE} no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::SITE_CODE} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:location_side].present?
                if row[:location_side].is_a?(String)
                  # TODO
                else
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::LOCATION_SIDE} no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::LOCATION_SIDE} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:breeding_site_type].present?
                if row[:breeding_site_type].is_a?(String)
                  unless breeding_site_type_options.include?(row[:breeding_site_type])
                    errors += ErrorFormater.new_error(
                      field: :base,
                      msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::BREEDING_SITE_TYPE} no tiene una opción válida",
                      custom_predicate: :not_found?
                    )
                  end
                else
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::BREEDING_SITE_TYPE} no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::BREEDING_SITE_TYPE} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:water_source_type].compact_blank.present?
                *rest, last = row[:water_source_type]
                unless rest.all? { |item| boolean?(item) }
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::WATER_SOURCE_TYPE} tiene valores que no son booleanos",
                    custom_predicate: :invalid_format?
                  )
                end
                if last.present? && !last.is_a?(String)
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::WATER_SOURCE_TYPE} último valor no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::WATER_SOURCE_TYPE} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:container_protection].compact_blank.present?
                *rest, last = row[:container_protection]
                unless rest.all? { |item| boolean?(item) }
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::CONTAINER_PROTECTION} tiene valores que no son booleanos",
                    custom_predicate: :invalid_format?
                  )
                end
                if last.present? && !last.is_a?(String)
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::CONTAINER_PROTECTION} último valor no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::CONTAINER_PROTECTION} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:was_chemically_treated].present?
                if row[:was_chemically_treated].is_a?(String)
                  unless was_chemically_treated_options.include?(row[:was_chemically_treated])
                    errors += ErrorFormater.new_error(
                      field: :base,
                      msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::WAS_CHEMICALLY_TREATED} no tiene una opción válida",
                      custom_predicate: :not_found?
                    )
                  end
                else
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::WAS_CHEMICALLY_TREATED} no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::WAS_CHEMICALLY_TREATED} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:type_content].compact_blank.present?
                unless row[:type_content].all? { |item| boolean?(item) }
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::TYPE_CONTENT} tiene valores que no son booleanos",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::TYPE_CONTENT} es requerido",
                  custom_predicate: :blank?
                )
              end

              if row[:elimination_method_type].compact_blank.present?
                *rest, last = row[:elimination_method_type]
                unless rest.all? { |item| boolean?(item) }
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::ELIMINATION_METHOD_TYPE} tiene valores que no son booleanos",
                    custom_predicate: :invalid_format?
                  )
                end
                if last.present? && !last.is_a?(String)
                  errors += ErrorFormater.new_error(
                    field: :base,
                    msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::ELIMINATION_METHOD_TYPE} último valor no es una cadena de texto",
                    custom_predicate: :invalid_format?
                  )
                end
              else
                errors += ErrorFormater.new_error(
                  field: :base,
                  msg: "#{CONTAINERS_SHEET_NAME} - Fila #{row_number}: #{ContainersHeaderQuestion::ELIMINATION_METHOD_TYPE} es requerido",
                  custom_predicate: :blank?
                )
              end
            end

            return Failure({ errors:, type: :invalid }) if errors.any?

            Success(input.merge(rows: [structured_visits_rows, structured_containers_rows]))
          end

          def extract_values(input) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
            visits_rows, containers_rows = input[:rows]

            questionnaire = input[:questionnaire]
            questions = questionnaire.questions
            breeding_site_type_question = questions.find_by!(question_text_es: ContainersHeaderQuestion::BREEDING_SITE_TYPE)
            container_protection_question = questions.find_by!(question_text_es: ContainersHeaderQuestion::CONTAINER_PROTECTION)
            elimination_method_type_question = questions.find_by!(question_text_es: ContainersHeaderQuestion::ELIMINATION_METHOD_TYPE)
            type_content_question = questions.find_by!(question_text_es: ContainersHeaderQuestion::TYPE_CONTENT)
            water_source_type_question = questions.find_by!(question_text_es: ContainersHeaderQuestion::WATER_SOURCE_TYPE)

            errors = []

            visits = visits_rows.map do |row| # rubocop:disable Metrics/BlockLength
              visit_permission_value, _other_visit_permission_value = row[:visit_permission]
              visit_permission_question = questions.find_by!(question_text_es: VisitsHeaderQuestion::VISIT_PERMISSION)
              visit_permission_option = visit_permission_question.options.find_by!(name_es: visit_permission_value)
              containers = containers_rows.filter { |r| row[:site_code] == r[:site_code] }
              family_education_topics = VisitsHeaderMultiselectOptions::FAMILY_EDUCATION_TOPICS
                                        .zip(row[:family_education_topics])
                                        .select { |_, keep| keep }
                                        .map(&:first)
              *_, other_family_education_topic_value = row[:family_education_topics]

              {
                house_id: House.find_by!(reference_code: row[:site_code]).id,
                visited_at: row[:date].in_time_zone,
                user_account_id: UserAccount.find_by!(username: row[:brigadist]).id,
                visit_permission: visit_permission_option.value == 1,
                host: VisitsHeaderMultiselectOptions::HOSTS
                  .zip(row[:hosts])
                  .select { |_, keep| keep }
                  .map(&:first),
                family_education_topics:,
                other_family_education_topic: family_education_topics.include?(VisitsHeaderMultiselectOptions::FAMILY_EDUCATION_TOPICS.last) ? other_family_education_topic_value : nil,
                answers: [
                  { "question_#{visit_permission_question.id}_0": visit_permission_option.id }
                ],
                inspections: containers.map do |r| # rubocop:disable Metrics/BlockLength
                  container_protection_values = ContainersHeaderMultiselectOptions::CONTAINER_PROTECTION
                                                .zip(r[:container_protection])
                                                .select { |_, keep| keep }
                                                .map(&:first)
                  elimination_method_type_values = ContainersHeaderMultiselectOptions::ELIMINATION_METHOD_TYPE
                                                   .zip(r[:elimination_method_type])
                                                   .select { |_, keep| keep }
                                                   .map(&:first)
                  type_content_values = ContainersHeaderMultiselectOptions::TYPE_CONTENT
                                        .zip(r[:type_content])
                                        .select { |_, keep| keep }
                                        .map(&:first)
                  water_source_type_values = ContainersHeaderMultiselectOptions::WATER_SOURCE_TYPE
                                             .zip(r[:water_source_type])
                                             .select { |_, keep| keep }
                                             .map(&:first)
                  breeding_site_type_option = breeding_site_type_question.options.find_by!(name_es: r[:breeding_site_type])
                  container_protection_options = container_protection_question.options.where(name_es: container_protection_values)
                  elimination_method_type_options = elimination_method_type_question.options.where(name_es: elimination_method_type_values)
                  type_content_options = type_content_question.options.where(name_es: type_content_values)
                  water_source_type_options = water_source_type_question.options.where(name_es: water_source_type_values)

                  {
                    breeding_site_type_id: option_identifier(breeding_site_type_option),
                    container_protection_ids: option_identifiers(container_protection_options),
                    other_protection: r[:container_protection].last,
                    elimination_method_type_ids: option_identifiers(elimination_method_type_options),
                    other_elimination_method: r[:elimination_method_type].last,
                    quantity_founded: 1,
                    was_chemically_treated: r[:was_chemically_treated],
                    type_content_id: option_identifiers(type_content_options),
                    water_source_type_ids: option_identifiers(water_source_type_options),
                    other_water_source: r[:water_source_type].last,
                    has_water: true
                  }
                end,
                notes: row[:notes] || '',
                was_offline: true
              }
            end

            return Failure({ errors:, type: :invalid }) if errors.any?

            Success(input.merge(visits:))
          end

          def create_visits(input) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
            visits = input[:visits]
            visit_summaries = []

            visits.each do |visit|
              result = Api::V1::Visits::Operations::Create.call(
                params: { json_params: visit.to_json },
                current_user: input[:current_user]
              )

              next unless result.success?

              created_visit = result.value![:ctx][:model]
              register_duplicate_candidates(created_visit)
              visit_summaries << {
                id: created_visit.id,
                houseName: House.find(created_visit.house_id).reference_code,
                containerCount: visit[:inspections].length || 0,
                duplicateVisitIds: created_visit.possible_duplicate_visit_ids
              }
            end

            ctx = { model: { visit_summaries: visit_summaries } }

            Success({ ctx:, type: :success })
          end

          private

          def get_rows(sheet, header_offset)
            rows = []

            ((sheet.first_row + header_offset)..sheet.last_row).each do |r|
              row = sheet.row(r)
              next if row.compact_blank.empty?

              rows << row
            end

            rows
          end

          def boolean?(value)
            value.is_a?(TrueClass) || value.is_a?(FalseClass)
          end

          def option_identifier(option)
            option.resource_id || option.id
          end

          def option_identifiers(options)
            options.map { |option| option_identifier(option) }
          end

          def register_duplicate_candidates(visit)
            return if visit.visited_at.blank?

            Visit.where(house_id: visit.house_id, visited_at: visit.visited_at.all_day)
                 .where.not(id: visit.id)
                 .find_each do |duplicate_visit|
              VisitDuplicateCandidate.find_or_create_by!(visit:, duplicate_visit:)
            end
          end
        end
      end
    end
  end
end
