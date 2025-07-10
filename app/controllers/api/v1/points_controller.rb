# frozen_string_literal: true

module Api
  module V1
    class PointsController < AuthorizedApiController
      def accumulated_points
        endpoint operation: Api::V1::Points::Operations::AccumulatedPoints,
                 renderer_options: { serializer: Api::V1::Points::Serializers::AccumulatedPoints },
                 options: { request:, current_user: }
      end

      def ranking
        endpoint operation: Api::V1::Points::Operations::Ranking,
                 renderer_options: { serializer: Api::V1::Points::Serializers::Ranking },
                 options: { request:, current_user: }
      end
    end
  end
end
