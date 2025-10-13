# frozen_string_literal: true

require 'roo'
require 'stringio'

module Api
  module V1
    module Visits
      module Operations
        class BulkUpload < ApplicationOperation
          VISITS_HEADERS = {
            site_code: 'Código de sitio',
            visit_date: 'Fecha',
            brigadista: 'Brigadista',
            permission: '¿Me dieron permiso para visitar la casa?',
            permission_other: 'Otra explicación - ¿Me dieron permiso para visitar la casa?',
            companions: '¿Quién te acompaña hoy en esta visita?',
            visit_start: '¿Dónde comienza la visita?',
            info_shared: '¿Qué información compartiste?',
            info_other: 'Otro tema importante - ¿Qué información compartiste?',
            notes: 'Agregar comentarios sobre la visita'
          }.freeze

          VISITS_MULTI_SELECT_HEADERS = [
            VISITS_HEADERS[:companions],
            VISITS_HEADERS[:info_shared]
          ].freeze

          VISIT_OPTION_QUESTION_MAP = {
            permission: '¿Me dieron permiso para visitar la casa?',
            companions: '¿Quién te acompaña hoy en esta visita?',
            visit_start: '¿Dónde comienza la visita?',
            info_shared: 'Por favor informemos a la familia sobre'
          }.freeze

          CONTAINER_HEADERS = {
            site_code: 'Código de sitio',
            location: 'Ubicación del contenedor',
            container_type: '¿Qué tipo de envase encontraste?',
            water_source: '¿De dónde proviene el agua?',
            water_source_other: 'Otro (tratamiento manual) - ¿De dónde proviene el agua?',
            protection: '¿El envase está protegido?',
            protection_other: 'Otro tipo de protección - ¿El envase está protegido?',
            chemically_treated: 'Pregunte si en los últimos 30 días: ¿fue el envase tratado por el Ministerio de Salud con piriproxifeno o abate?',
            contents: 'En este envase hay..',
            action: '¿Qué acción se realizó con el envase?',
            action_other: 'Otro - ¿Qué acción se realizó con el envase?'
          }.freeze

          CONTAINER_MULTI_SELECT_HEADERS = [
            CONTAINER_HEADERS[:contents]
          ].freeze

          CONTAINER_OPTION_QUESTION_MAP = {
            container_type: '¿Qué tipo de contenedor encontraste?',
            water_source: '¿De dónde proviene el agua?',
            protection: '¿El contenedor está protegido?',
            chemically_treated: 'Pregunte si en los últimos 30 días: ¿fue el contenedor tratado por el Ministerio de Salud con piriproxifeno o abate?',
            contents: 'En este contenedor hay...',
            action: '¿Qué acción se realizó con el contenedor?'
          }.freeze

          step :validate_schema
          step :parse
          step :transform
          step :create

          def validate_schema(input)
            params = input[:params] || {}
            contract = Api::V1::Visits::Contracts::BulkUpload.kall(params)
            return Success(input.merge(contract: contract)) if contract.success?

            errors = contract.errors.map do |error|
              ErrorFormater.new_error(
                field: error.path.last || :file,
                msg: error.text,
                path: error.path,
                custom_predicate: error.predicate
              )
            end.flatten

            Failure({ ctx: { 'contract.default' => contract }, type: :invalid, errors: errors })
          end

          def parse(input)
            params = input[:params]
            upload = params[:file]
            tempfile = upload.tempfile

            begin
              xlsx = Roo::Excelx.new(tempfile.path)
              upload_data = File.binread(tempfile.path)
              Success({ file: xlsx, upload: upload, upload_data: upload_data })
            rescue StandardError => error
              errors = ErrorFormater.new_error(
                field: :file,
                msg: 'is not a readable Excel file',
                custom_predicate: :format?,
                meta: { detail: error.message }
              )

              Failure({ ctx: { 'contract.default' => nil }, type: :invalid, errors: errors })
            end
          end

          def transform(input)
            file = input[:file]
            upload = input[:upload]
            upload_data = input[:upload_data]

            visits_rows = parse_sheet(
              file.sheet('Visitas'),
              VISITS_HEADERS.values,
              multi_select_headers: VISITS_MULTI_SELECT_HEADERS
            )
            containers_rows = parse_sheet(
              file.sheet('Envases'),
              CONTAINER_HEADERS.values,
              multi_select_headers: CONTAINER_MULTI_SELECT_HEADERS
            )

            questionnaire = Questionnaire.includes(questions: :options).find_by(current_form: true)
            unless questionnaire
              errors = ErrorFormater.new_error(field: :file,
                                               msg: 'No se encontró un formulario activo para procesar las visitas',
                                               custom_predicate: :not_found?)

              return Failure({ ctx: { 'contract.default' => input[:contract] }, type: :invalid, errors: errors })
            end

            houses = load_houses(visits_rows, containers_rows)
            users = load_users(visits_rows)
            option_lookup = build_option_lookup(questionnaire)

            visit_result = build_visit_entries(
              visits_rows: visits_rows,
              houses: houses,
              users: users,
              questionnaire: questionnaire,
              option_lookup: option_lookup
            )

            container_result = build_container_entries(
              containers_rows: containers_rows,
              houses: houses,
              option_lookup: option_lookup
            )

            errors = visit_result[:errors] + container_result[:errors]
            if errors.any?
              return Failure({ ctx: { 'contract.default' => input[:contract] }, type: :invalid,
                               errors: errors.flatten })
            end

            Success(
              input.merge(
                visit_attributes: visit_result[:entries],
                containers: container_result[:entries],
                upload: upload,
                upload_data: upload_data,
                questionnaire: questionnaire
              )
            )
          end

          def create(input)
            visit_attributes = input[:visit_attributes]
            upload = input[:upload]
            upload_data = input[:upload_data]
            containers = input[:containers] || []

            created_visits = Visit.transaction do
              visit_attributes.map do |attributes|
                Visit.create!(attributes).tap do |visit|
                  attach_upload(visit, upload, upload_data)
                end
              end
            end

            containers_by_code = containers.group_by do |container|
              normalize_code(container[:site_code])
            end

            visit_summaries = created_visits.map do |visit|
              house = visit.house
              site_code = normalize_code(house&.reference_code)

              {
                id: visit.id,
                houseId: house&.id,
                houseName: house&.reference_code,
                containerCount: containers_by_code.fetch(site_code, []).size
              }
            end

            response_ctx = {
              model: {
                visit_summaries: visit_summaries
              }
            }

            Success({ ctx: response_ctx, type: :success })
          end

          private

          def parse_sheet(sheet, expected_headers, multi_select_headers: [])
            multi_select_info = detect_multi_select_layout(sheet, expected_headers, multi_select_headers)
            return parse_sheet_with_multi_select(sheet, multi_select_info) if multi_select_info

            parse_sheet_basic(sheet, expected_headers)
          end

          def parse_sheet_basic(sheet, expected_headers)
            sheet.parse(headers: true).each_with_index.filter_map do |row, index|
              next if row.values.all?(&:blank?)
              next if header_row?(row, expected_headers)

              { row_number: index + 2, data: row }
            end
          end

          def parse_sheet_with_multi_select(sheet, multi_select_info)
            headers = multi_select_info[:headers]
            data_start_row = multi_select_info[:data_start_row]
            multi_select_header_names = headers.select { |info| info[:multi_select] }
                                               .filter_map { |info| info[:header] }
                                               .uniq
            headers_with_options = headers.select { |info| info[:option].present? }
                                          .filter_map { |info| info[:header] }
                                          .uniq
            last_row = sheet.last_row.to_i

            return [] if last_row < data_start_row

            (data_start_row..last_row).each_with_object([]) do |row_index, collection|
              row_values = headers.each_index.map { |col_idx| sheet.cell(row_index, col_idx + 1) }
              next if row_values.all?(&:blank?)

              row_data = {}

              headers.each_with_index do |header_info, col_idx|
                header = header_info[:header]
                next if header.blank?

                cell_value = row_values[col_idx]

                if header_info[:option].present?
                  next unless checkbox_selected?(cell_value)

                  row_data[header] ||= []
                  row_data[header] << header_info[:option]
                elsif header_info[:multi_select]
                  next unless checkbox_selected?(cell_value)

                  row_data[header] ||= []
                  row_data[header] << cell_value
                else
                  row_data[header] = cell_value
                end
              end

              headers_with_options.each do |header|
                values = Array(row_data[header])
                next if values.blank?

                cleaned_values = values.map { |value| clean_cell(value) }
                                       .compact_blank
                                       .uniq

                if cleaned_values.empty?
                  row_data[header] = multi_select_header_names.include?(header) ? [] : nil
                  next
                end

                row_data[header] = if multi_select_header_names.include?(header)
                                     cleaned_values
                                   else
                                     cleaned_values.first
                                   end
              end

              next if row_data.values.all?(&:blank?)

              collection << { row_number: row_index, data: row_data }
            end
          end

          def detect_multi_select_layout(sheet, expected_headers, multi_select_headers)
            sanitized_multi_headers = Array(multi_select_headers).map { |header| sanitize_header(header) }.to_set
            return nil if sanitized_multi_headers.empty?
            return nil if sheet.last_row.to_i < 2

            first_row = sheet.row(1)
            second_row = sheet.row(2)
            return nil if second_row.blank? || second_row.all?(&:blank?)

            expected_map = expected_headers.index_by { |header| sanitize_header(header) }

            column_count = [first_row.length, second_row.length].max
            column_count = expected_headers.length if column_count.zero?

            headers = []
            current_header = nil
            found_multi_select_column = false
            non_multi_value_present = false

            column_count.times do |index|
              top_value = first_row[index]
              current_header = top_value.presence || current_header
              sanitized_header = sanitize_header(current_header)
              sub_header_value = second_row[index]
              sanitized_sub_header = sanitize_header(sub_header_value)

              if sanitized_header.present? && sanitized_multi_headers.include?(sanitized_header) &&
                 sanitized_sub_header.present?
                found_multi_select_column = true
                header_name = expected_map[sanitized_header] || current_header&.to_s&.strip

                headers << {
                  header: header_name,
                  option: clean_cell(sub_header_value),
                  multi_select: true
                }
              else
                sanitized_top_value = sanitize_header(top_value)
                header_name = expected_map[sanitized_header] || expected_map[sanitized_top_value] ||
                              sanitized_header.presence || sanitized_top_value.presence
                option_name = sanitized_sub_header.present? ? clean_cell(sub_header_value) : nil
                headers << { header: header_name, option: option_name, multi_select: false }

                non_multi_value_present ||= sanitized_sub_header.present? &&
                                            sanitized_multi_headers.exclude?(sanitized_header)
              end
            end

            found_multi_select_column ||= headers.any? { |info| info[:option].present? }

            return nil if non_multi_value_present && !found_multi_select_column
            return nil unless found_multi_select_column

            { headers: headers, data_start_row: 3 }
          end

          def header_row?(row_hash, expected_headers)
            values = row_hash.values.compact.filter_map { |value| sanitize_header(value) }
            return false if values.empty?

            expected_set = expected_headers.filter_map { |header| sanitize_header(header) }.to_set
            values.all? { |value| expected_set.include?(value) }
          end

          def sanitize_header(value)
            clean_cell(value).presence
          end

          def checkbox_selected?(value)
            return true if value == true
            return false if value == false || value.nil?

            normalized = value.to_s.strip
            return false if normalized.empty?

            normalized_downcase = normalized.downcase
            return false if %w[false 0 no].include?(normalized_downcase)

            true
          end

          def load_houses(visits_rows, containers_rows)
            visit_codes = visits_rows.filter_map { |row| normalize_code(row[:data][VISITS_HEADERS[:site_code]]) }
            container_codes = containers_rows.filter_map do |row|
              normalize_code(row[:data][CONTAINER_HEADERS[:site_code]])
            end
            codes = (visit_codes + container_codes).compact.uniq

            House.where(reference_code: codes).index_by { |house| normalize_code(house.reference_code) }
          end

          def load_users(visits_rows)
            usernames = visits_rows.filter_map do |row|
              normalize_username(row[:data][VISITS_HEADERS[:brigadista]])
            end.uniq
            UserAccount.includes(user_profile: :team)
                       .where(username: usernames)
                       .index_by { |user| normalize_username(user.username) }
          end

          def build_option_lookup(questionnaire)
            questionnaire.questions.each_with_object({}) do |question, memo|
              memo[question.question_text_es] = question.options.each_with_object({}) do |option, collection|
                [option.name_es, option.name_en, option.name_pt].compact.each do |name|
                  collection[normalize_text(name)] = option
                end
              end
            end
          end

          def build_visit_entries(visits_rows:, houses:, users:, questionnaire:, option_lookup:)
            entries = []
            errors = []

            visits_rows.each do |row|
              row_errors = []
              data = row[:data]
              row_number = row[:row_number]

              site_code_raw = data[VISITS_HEADERS[:site_code]]
              site_code = normalize_code(site_code_raw)
              if site_code.blank?
                row_errors << row_error(:visits, row_number, VISITS_HEADERS[:site_code],
                                        'El código de sitio es obligatorio')
              end

              house = houses[site_code]
              unless house
                row_errors << row_error(:visits, row_number, VISITS_HEADERS[:site_code],
                                        "La vivienda con código #{site_code_raw} no existe",
                                        predicate: :not_found?)
              end

              username_raw = data[VISITS_HEADERS[:brigadista]]
              username = normalize_username(username_raw)
              if username.blank?
                row_errors << row_error(:visits, row_number, VISITS_HEADERS[:brigadista],
                                        'El brigadista es obligatorio')
              end

              user_account = users[username]
              unless user_account
                row_errors << row_error(:visits, row_number, VISITS_HEADERS[:brigadista],
                                        "No existe un brigadista con usuario #{username_raw}",
                                        predicate: :not_found?)
              end

              team = user_account&.user_profile&.team
              unless team
                row_errors << row_error(:visits, row_number, VISITS_HEADERS[:brigadista],
                                        "El brigadista #{username_raw} no tiene un equipo asignado",
                                        predicate: :not_found?)
              end

              permission_value = data[VISITS_HEADERS[:permission]]
              if permission_value.blank?
                row_errors << row_error(:visits, row_number, VISITS_HEADERS[:permission],
                                        'Debe indicar si obtuvo permiso para la visita')
              end

              permission_option = find_option(option_lookup, VISIT_OPTION_QUESTION_MAP[:permission], permission_value,
                                              VISITS_HEADERS[:permission])
              unless permission_option
                row_errors << row_error(:visits, row_number, VISITS_HEADERS[:permission],
                                        "La opción '#{permission_value}' no es válida",
                                        predicate: :not_exists?)
              end

              companions_values = split_values(data[VISITS_HEADERS[:companions]])
              companion_options, companion_errors = map_options(
                option_lookup: option_lookup,
                question_text: VISIT_OPTION_QUESTION_MAP[:companions],
                values: companions_values,
                header: VISITS_HEADERS[:companions],
                row_number: row_number,
                sheet: :visits
              )

              info_values = split_values(data[VISITS_HEADERS[:info_shared]])
              info_options, info_errors = map_options(
                option_lookup: option_lookup,
                question_text: VISIT_OPTION_QUESTION_MAP[:info_shared],
                values: info_values,
                header: VISITS_HEADERS[:info_shared],
                row_number: row_number,
                sheet: :visits
              )

              row_errors.concat(companion_errors)
              row_errors.concat(info_errors)

              visit_date = parse_visit_date(data[VISITS_HEADERS[:visit_date]])
              unless visit_date
                row_errors << row_error(:visits, row_number, VISITS_HEADERS[:visit_date],
                                        "La fecha '#{data[VISITS_HEADERS[:visit_date]]}' no es válida",
                                        predicate: :invalid?)
              end

              if row_errors.empty?
                entries << {
                  house: house,
                  user_account: user_account,
                  team: team,
                  questionnaire: questionnaire,
                  answers: [],
                  family_education_topics: info_values,
                  other_family_education_topic: data[VISITS_HEADERS[:info_other]],
                  host: companions_values.any? ? companions_values.join(', ') : nil,
                  status: '',
                  notes: data[VISITS_HEADERS[:notes]],
                  visit_permission: permission_option&.value.to_s == '1',
                  was_offline: false,
                  created_at: visit_date,
                  updated_at: visit_date
                }
              else
                errors.concat(row_errors)
              end
            end

            { entries: entries, errors: errors }
          end

          def build_container_entries(containers_rows:, houses:, option_lookup:)
            entries = []
            errors = []

            containers_rows.each do |row|
              row_errors = []
              data = row[:data]
              row_number = row[:row_number]

              site_code_raw = data[CONTAINER_HEADERS[:site_code]]
              site_code = normalize_code(site_code_raw)
              if site_code.blank?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:site_code],
                                        'El código de sitio es obligatorio')
              end

              house = houses[site_code]
              unless house
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:site_code],
                                        "La vivienda con código #{site_code_raw} no existe",
                                        predicate: :not_found?)
              end

              type_value = data[CONTAINER_HEADERS[:container_type]]
              type_option = find_option(option_lookup, CONTAINER_OPTION_QUESTION_MAP[:container_type], type_value,
                                        CONTAINER_HEADERS[:container_type])
              if type_value.blank?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:container_type],
                                        'Debe indicar el tipo de envase encontrado')
              elsif type_option.nil?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:container_type],
                                        "La opción '#{type_value}' no es válida",
                                        predicate: :not_exists?)
              end

              water_source_value = data[CONTAINER_HEADERS[:water_source]]
              water_source_option = find_option(option_lookup, CONTAINER_OPTION_QUESTION_MAP[:water_source], water_source_value,
                                                CONTAINER_HEADERS[:water_source])
              if water_source_value.blank?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:water_source],
                                        'Debe indicar de dónde proviene el agua')
              elsif water_source_option.nil?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:water_source],
                                        "La opción '#{water_source_value}' no es válida",
                                        predicate: :not_exists?)
              end

              protection_value = data[CONTAINER_HEADERS[:protection]]
              protection_option = find_option(option_lookup, CONTAINER_OPTION_QUESTION_MAP[:protection], protection_value,
                                              CONTAINER_HEADERS[:protection])
              if protection_value.blank?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:protection],
                                        'Debe indicar cómo está protegido el envase')
              elsif protection_option.nil?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:protection],
                                        "La opción '#{protection_value}' no es válida",
                                        predicate: :not_exists?)
              end

              treated_value = data[CONTAINER_HEADERS[:chemically_treated]]
              treated_option = find_option(option_lookup, CONTAINER_OPTION_QUESTION_MAP[:chemically_treated], treated_value,
                                           CONTAINER_HEADERS[:chemically_treated])
              if treated_value.blank?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:chemically_treated],
                                        'Debe indicar si el envase fue tratado químicamente')
              elsif treated_option.nil?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:chemically_treated],
                                        "La opción '#{treated_value}' no es válida",
                                        predicate: :not_exists?)
              end

              contents_values = split_values(data[CONTAINER_HEADERS[:contents]])
              if contents_values.empty?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:contents],
                                        'Debe indicar qué se encontró en el envase')
              end

              content_options, content_errors = map_options(
                option_lookup: option_lookup,
                question_text: CONTAINER_OPTION_QUESTION_MAP[:contents],
                values: contents_values,
                header: CONTAINER_HEADERS[:contents],
                row_number: row_number,
                sheet: :containers
              )

              row_errors.concat(content_errors)

              action_value = data[CONTAINER_HEADERS[:action]]
              action_option = find_option(option_lookup, CONTAINER_OPTION_QUESTION_MAP[:action], action_value,
                                          CONTAINER_HEADERS[:action])
              if action_value.blank?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:action],
                                        'Debe indicar qué acción se realizó con el envase')
              elsif action_option.nil?
                row_errors << row_error(:containers, row_number, CONTAINER_HEADERS[:action],
                                        "La opción '#{action_value}' no es válida",
                                        predicate: :not_exists?)
              end

              if row_errors.empty?
                entries << {
                  row_number: row_number,
                  site_code: site_code_raw,
                  location: data[CONTAINER_HEADERS[:location]],
                  container_type: type_option,
                  water_source: water_source_option,
                  water_source_other: data[CONTAINER_HEADERS[:water_source_other]],
                  protection: protection_option,
                  protection_other: data[CONTAINER_HEADERS[:protection_other]],
                  chemically_treated: treated_option,
                  contents: content_options,
                  action: action_option,
                  action_other: data[CONTAINER_HEADERS[:action_other]]
                }
              else
                errors.concat(row_errors)
              end
            end

            { entries: entries, errors: errors }
          end

          def map_options(option_lookup:, question_text:, values:, header:, row_number:, sheet:)
            options = []
            errors = []
            values.each do |value|
              option = find_option(option_lookup, question_text, value, header)
              if option.nil?
                errors << row_error(sheet, row_number, header,
                                    "La opción '#{value}' no es válida",
                                    predicate: :not_exists?)
              else
                options << option
              end
            end
            [options, errors]
          end

          def find_option(option_lookup, question_text, value, header = nil)
            return nil if value.blank?

            index = option_lookup[question_text] || option_lookup[header]
            return nil unless index

            index[normalize_text(value)]
          end

          def split_values(value)
            return value.map { |part| clean_cell(part) }.compact_blank.uniq if value.is_a?(Array)
            return [] if value.blank?

            value.to_s.split(',').map { |part| clean_cell(part) }.compact_blank
          end

          def clean_cell(value)
            value.to_s.tr('“”’‘', '"').gsub(/\A["']+|["']+\z/, '').strip
          end

          def parse_visit_date(value)
            return value.in_time_zone if value.respond_to?(:in_time_zone)
            return value.to_datetime.in_time_zone if value.is_a?(Date)
            return value.in_time_zone if value.is_a?(Time)

            string_value = value.to_s
            return nil if string_value.blank?

            Date.strptime(string_value, '%d/%m/%Y').in_time_zone
          rescue ArgumentError, TypeError
            begin
              Time.zone.parse(string_value)
            rescue ArgumentError, TypeError
              nil
            end
          end

          def row_error(sheet, row_number, column, message, predicate: :invalid?)
            field_prefix = sheet == :visits ? 'visits' : 'containers'
            field_column = column.to_s.parameterize(separator: '_')
            field = "#{field_prefix}.row_#{row_number}.#{field_column}"

            ErrorFormater.new_error(field: field, msg: message, custom_predicate: predicate)
          end

          def normalize_text(value)
            sanitized = value.to_s.tr('“”’‘', '"')
            sanitized = sanitized.strip
            sanitized = sanitized.gsub(/\A["']+|["']+\z/, '').strip

            ActiveSupport::Inflector.transliterate(sanitized).downcase.gsub(/\s+/, ' ')
          end

          def normalize_code(value)
            value.to_s.strip.upcase.presence
          end

          def normalize_username(value)
            value.to_s.strip.downcase.presence
          end

          def attach_upload(visit, upload, data)
            return if upload.nil? || data.blank?

            visit.upload_file.attach(
              io: StringIO.new(data),
              filename: upload.original_filename,
              content_type: upload.content_type
            )
          end
        end
      end
    end
  end
end
