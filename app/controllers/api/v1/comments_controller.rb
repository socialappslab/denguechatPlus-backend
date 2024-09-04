module Api
  module V1
    class CommentsController < ApplicationController
      def index
        endpoint operation: Api::V1::Comments::Operations::Index,
                 renderer_options: { serializer: Api::V1::Comments::Serializers::Index },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::Comments::Operations::Show,
                 renderer_options: { serializer: Api::V1::Comments::Serializers::Index },
                 options: { current_user: }
      end

      def create
        endpoint operation: Api::V1::Comments::Operations::Create,
                 renderer_options: { serializer: Api::V1::Comments::Serializers::Show },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::Comments::Operations::Update,
                 renderer_options: { serializer: Api::V1::Comments::Serializers::Show },
                 options: { current_user: }
      end

      def destroy
        endpoint operation: Api::V1::Comments::Operations::Destroy,
                 options: { current_user: }
      end
    end
  end
end
