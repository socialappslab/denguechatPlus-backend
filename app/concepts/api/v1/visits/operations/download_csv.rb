# frozen_string_literal: true

require "csv"

module Api
  module V1
    module Visits
      module Operations
        class DownloadCsv < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_params!
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

          def generate_csv(_input = nil)
            visit = Visit.includes(:house, :user_account, :team, :inspections).find(@params[:id])

            csv_data = CSV.generate(headers: true) do |csv|
              csv << visit_headers
              csv << visit_row(visit)

              csv << []
              csv << []

              csv << inspection_headers
              visit.inspections.each { |inspection| csv << inspection_row(inspection) }
            end

            Success(
              send_data: {
                data: csv_data,
                filename: "visita_#{visit.id}.csv",
                type: "text/csv"
              },
              type: :send_data
            )
          end

          private

          def visit_headers
            [
              "codigo de referencia",
              "fecha_visita",
              "brigadista",
              "brigada",
              "permiso para visitar la casa",
              "notas"
            ]
          end

          def visit_row(visit)
            [
              visit.house&.reference_code,
              visit.visited_at.strftime("%d/%m/%Y %H:%M"),
              visit.user_account&.full_name,
              visit.team&.name,
              visit.visit_permission ? "Sí" : "No",
              visit.notes
            ]
          end

          def inspection_headers
            %w[tipo_de_recipiente
              hay_agua_en_el_recipiente
              origen_del_agua
              otro_origen_del_agua
              tipo_de_protección
              otro_tipo_de_protección
              fue_tratado_por_el_ministerio_de_salud
              en_reste_recipiente/envase_hay
              acción_realizada_sobre_el_recipiente
              otra_acción
              foto_del_recipiente/envase]
          end

          def inspection_row(inspection)
            [
              inspection.breeding_site_type.name&.gsub(',', '-'),
              inspection.has_water ? 'Sí' : 'No',
              inspection&.water_source_type&.name&.gsub(',', '-'),
              inspection.water_source_other,
              inspection.container_protections&.pluck(:name_es)&.join("-"),
              inspection.other_protection,
              inspection.was_chemically_treated,
              inspection.type_contents&.pluck(:name_es)&.join("-"),
              inspection.elimination_method_type&.name_es&.gsub(',', '-'),
              inspection.other_elimination_method,
              inspection.photo.present? ? Rails.application.routes.url_helpers.url_for(inspection.photo) : ''

            ]
          end

          def bool(value)
            value ? "Sí" : "No"
          end
        end
      end
    end
  end
end
