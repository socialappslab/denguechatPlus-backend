# frozen_string_literal: true

require "csv"

module Api
  module V1
    module Visits
      module Operations
        class DownloadCsv < ApplicationOperation
          include Dry::Transaction

          step :generate_csv

          def generate_csv(_input = nil)
            csv_data = CSV.generate(headers: true) do |csv|
              csv << %w[id has_water]

              Visit.first.inspections.find_each do |inspection|
                csv << [inspection.id, inspection.has_water]
              end
            end

            Success(csv_data)
          end
        end
      end
    end
  end
end
