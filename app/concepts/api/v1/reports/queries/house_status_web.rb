# frozen_string_literal: true


module Api
  module V1
    module Reports
      module Queries
        class HouseStatusWeb
          include Api::V1::Lib::Queries::QueryHelper

          StatusResults = Struct.new(:house_quantity, :visit_quantity, :site_variation_percentage, :visit_variation_percentage,
                                     :green_quantity, :orange_quantity, :red_quantity)


          def initialize(filter, current_user)
            @model = HouseStatus
            filter ||= {}
            @current_user = current_user
            @wedge_id =filter[:wedge_id]
            @team_id = filter[:team_id]
            @neighborhood_id =filter[:neighborhood_id]
            @filter = filter
          end

          def self.call(...)
            new(...).call
          end

          def call
            fetch_data
          end

          private

          attr_reader :team_id, :wedge_id, :neighborhood_id

          def fetch_data
            query = <<~SQL.squish
              SELECT 
                CASE 
                  WHEN status = '0' THEN 'greenQuantity'
                  WHEN status = '1' THEN 'yellowQuantity'
                  WHEN status = '2' THEN 'redQuantity'
                END AS category,
                COUNT(*) AS cantidad
              FROM houses
              where status is not null
              GROUP BY status;
            SQL

            result = ActiveRecord::Base.connection.execute(query)
            result_hash = result.each_with_object({}) do |row, hash|
              hash[row['category'].to_sym] = row['cantidad']
            end || {}

            StatusResults.new(
              0,
              0,
              0,
              0,
              result_hash[:greenQuantity] || nil,
              result_hash[:yellowQuantity] || nil,
              result_hash[:redQuantity] || nil
            )
          end

        end
      end
    end
  end
end
