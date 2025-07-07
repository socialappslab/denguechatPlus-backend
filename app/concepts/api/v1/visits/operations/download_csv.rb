# frozen_string_literal: true

require 'csv'

module Api
  module V1
    module Visits
      module Operations
        class DownloadCsv < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_params!
          tee :set_language
          step :generate_csv

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_params!
            @ctx['contract.default'] = Api::V1::Visits::Contracts::DownloadInformation.kall(@params)
            return Success({ ctx: @ctx, type: :success }) if @ctx['contract.default'].success?

            Failure({ ctx: @ctx, type: :invalid })
          end

          def set_language
            @language = @params[:language].in?(%w[en es pt]) || 'es'
          end

          def generate_csv(_input = nil)
            visit = Visit
                      .includes(
                        :house,
                        :user_account,
                        :team,
                        inspections: [
                          :breeding_site_type,
                          :water_source_types,
                          :container_protections,
                          :type_contents,
                          :elimination_method_types,
                          :photo_attachment, :photo_blob
                        ]
                      ).find(@params[:id])

            csv_data = CSV.generate(headers: true) do |csv|
              csv << Constants::DownloadCsvConstants.const_get("VISIT_HEADERS_#{@language.upcase}")
              csv << visit_row(visit)

              csv << []
              csv << []

              csv << Constants::DownloadCsvConstants.const_get("INSPECTION_HEADERS_#{@language.upcase}")
              visit.inspections.each { |inspection| csv << inspection_row(inspection) }
            end

            Success(
              send_data: {
                data: csv_data,
                filename: "visita_#{visit.id}.csv",
                type: 'text/csv'
              },
              type: :send_data
            )
          end

          private

          def visit_row(visit)
            [
              visit.house&.reference_code,
              visit.visited_at.strftime('%d/%m/%Y %H:%M'),
              visit.user_account&.full_name,
              visit.team&.name,
              Constants::DownloadCsvConstants::BOOLEAN_TRANSLATIONS[@language][visit.visit_permission],
              visit.notes,
              translate_multilang_values(Constants::DownloadCsvConstants::QUESTION_TALK_ABOUT_TOPICS,
                                         @language,
                                         visit.family_education_topics)&.join('-')
            ]
          end

          def inspection_row(inspection)
            [
              inspection.id,
              inspection.breeding_site_type.send(:"name_#{@language}"),
              Constants::DownloadCsvConstants::BOOLEAN_TRANSLATIONS[@language][inspection.has_water],
              inspection&.water_source_types&.pluck(:"name_#{@language}")&.join('-'),
              inspection.water_source_other,
              inspection.container_protections&.pluck(:"name_#{@language}")&.join('-'),
              inspection.other_protection,
              translate_multilang_values(Constants::DownloadCsvConstants::WAS_CHEMICALLY_TRANSLATIONS,
                                         @language,
                                         inspection.was_chemically_treated)&.join('-'),
              inspection.type_contents&.pluck(:"name_#{@language}")&.join('-'),
              inspection.elimination_method_types&.pluck(:"name_#{@language}")&.join('-'),
              inspection.other_elimination_method,
              inspection.photo.present? ? Rails.application.routes.url_helpers.url_for(inspection.photo) : ''

            ]
          end

          def bool(value)
            value ? 'Sí' : 'No'
          end

          def translate_multilang_values(collection, language = 'es', current_value = nil)
            return '' unless current_value

            values = Array(current_value)

            values.map do |val|
              match = collection.find do |q|
                q[:name_en] == val || q[:name_es] == val || q[:name_pt] == val
              end

              if match
                match[:"name_#{language}"]
              else
                val
              end
            end
          end
        end
      end
    end
  end
end