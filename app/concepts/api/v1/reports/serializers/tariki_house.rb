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
            (report.tariki_houses_qty.to_f / report.total_houses_qty.to_f) * 100
          end

        end
      end
    end
  end
end
