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

    end
  end
end
