# frozen_string_literal: true

module Api
  module V1
    class ReportsController < AuthorizedApiController
      def house_status
        endpoint operation: Api::V1::Reports::Operations::HouseStatus,
                 renderer_options: { serializer: Api::V1::Reports::Serializers::HouseStatus },
                 options: { request:, current_user: }
      end

      def brigadists_performance
        endpoint operation: Api::V1::Reports::Operations::BrigadistPerformance,
                 renderer_options: { serializer: Api::V1::Reports::Serializers::BrigadistPerformance },
                 options: { request:, current_user: }
      end

      def tariki_houses
        endpoint operation: Api::V1::Reports::Operations::TarikiHouse,
                 renderer_options: { serializer: Api::V1::Reports::Serializers::TarikiHouse },
                 options: { request:, current_user: }
      end
    end
  end
end
