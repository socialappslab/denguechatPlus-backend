module Api
  module V1
    class LikesController < ApplicationController
      def index
        endpoint operation: Api::V1::Likes::Operations::Index,
                 renderer_options: { serializer: Api::V1::Likes::Serializers::Index },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::Likes::Operations::Show,
                 renderer_options: { serializer: Api::V1::Likes::Serializers::Index },
                 options: { current_user: }
      end

      def create
        endpoint operation: Api::V1::Likes::Operations::Create,
                 renderer_options: { serializer: Api::V1::Likes::Serializers::Show },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::Likes::Operations::Update,
                 renderer_options: { serializer: Api::V1::Likes::Serializers::Show },
                 options: { current_user: }
      end

      def destroy
        endpoint operation: Api::V1::Likes::Operations::Destroy,
                 options: { current_user: }
      end
    end
  end
end
