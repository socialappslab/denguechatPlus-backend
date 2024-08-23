# frozen_string_literal: true

module Api
  module V1
    class NeighborhoodsController < AuthorizedApiController

      def index
        endpoint operation: Api::V1::Neighborhoods::Operations::Index,
                 renderer_options: { serializer: Api::V1::Neighborhoods::Serializers::Index },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::Neighborhoods::Operations::Show,
                 renderer_options: { serializer: Api::V1::Neighborhoods::Serializers::Show },
                 options: { current_user: }
      end

      def create
        endpoint operation: Api::V1::Neighborhoods::Operations::Create,
                 renderer_options: { serializer: Api::V1::Neighborhoods::Serializers::Show },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::Neighborhoods::Operations::Update,
                 renderer_options: { serializer: Api::V1::Neighborhoods::Serializers::Show },
                 options: { current_user: }
      end

      def destroy
        endpoint operation: Api::V1::Neighborhoods::Operations::Destroy,
                 options: { current_user: }
      end

    end
  end
end
