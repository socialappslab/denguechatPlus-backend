# frozen_string_literal: true

module Api
  module V1
    class HouseBlocksController < AuthorizedApiController

      def index
        endpoint operation: Api::V1::HouseBlocks::Operations::Index,
                 renderer_options: {
                   serializer: Api::V1::HouseBlocks::Serializers::Index
                 },
                 options: { current_user: }
      end

    end
  end
end
