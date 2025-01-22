# frozen_string_literal: true

module Api
  module V1
    class HousesController < AuthorizedApiController

      def index
        endpoint operation: Api::V1::Houses::Operations::Index,
                 renderer_options: {
                   serializer: Api::V1::Houses::Serializers::Index
                 },
                 options: { current_user: }
      end

      def list_to_visit
        endpoint operation: Api::V1::Houses::Operations::ListToVisit,
                 renderer_options: {
                   serializer: Api::V1::Houses::Serializers::ListToVisit
                 },
                 options: { current_user: }
      end

      def orphan_houses
        endpoint operation: Api::V1::Houses::Operations::OrphanHouse,
                 renderer_options: {
                   serializer: Api::V1::Houses::Serializers::Index
                 },
                 options: { current_user: }
      end

    end
  end
end
