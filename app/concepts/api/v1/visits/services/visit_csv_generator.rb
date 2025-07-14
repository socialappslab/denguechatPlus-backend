# frozen_string_literal: true

require 'csv'

module Api
  module V1
    module Visits
      module Services
        class VisitCsvGenerator
          FILENAME = 'visit_data.csv'
          ATTRIBUTES = %w[house_id visited_at family_education_topics].freeze

          def self.call(...)
            new(...).call
          end

          def initialize(visit)
            @visit = visit
          end

          def call
            { file: csv_file, filename: FILENAME }
          end

          private

          attr_reader :visit

          def csv_file
            CSV.generate(headers: true) do |csv|
              csv << ATTRIBUTES.map(&:humanize)
              visit.find_each { |visit| csv << visit_to_csv(visit) }
            end
          end

          def visit_to_csv(visit)
            ATTRIBUTES.map { |attribute| visit.public_send(attribute) }
          end
        end
      end
    end
  end
end
