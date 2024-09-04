# frozen_string_literal: true

module Api
  module V1
    class WedgesController < AuthorizedApiController

      def index
        endpoint operation: Api::V1::Wedges::Operations::Index,
                 renderer_options: { serializer: Api::V1::Wedges::Serializers::Index }
      end

      def show
        endpoint operation: Api::V1::Wedges::Operations::Show,
                 renderer_options: { serializer: Api::V1::Wedges::Serializers::Show }
      end

    end
  end
end
