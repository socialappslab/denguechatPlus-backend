# frozen_string_literal: true

module Api
  module V1
    module Reports
      module Serializers
        class TarikiHouse
          include Alba::Resource
          transform_keys :lower_camel

          attributes :total_houses_qty, :tariki_houses_qty

          attribute :tariki_percentage do |report|
            next 0 if report.total_houses_qty.blank? || report.total_houses_qty < 1

            (report.tariki_houses_qty.to_f / report.total_houses_qty.to_f) * 100
          end

          attributes :green_container_qty, :total_container_qty

          attribute :green_container_percentage do |report|
            next 0 if report.total_container_qty.blank? || report.green_container_qty < 1

            (report.green_container_qty.to_f / report.total_container_qty.to_f) * 100
          end
        end
      end
    end
  end
end
