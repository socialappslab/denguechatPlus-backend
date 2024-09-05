# frozen_string_literal: true

module Api
  module V1
    class PostsController < AuthorizedApiController

      def show
        endpoint operation: Api::V1::Posts::Operations::Show,
                 renderer_options: { serializer: Api::V1::Posts::Serializers::Show },
                 options: { current_user: }
      end

      def create
        endpoint operation: Api::V1::Posts::Operations::Create,
                 renderer_options: { serializer: Api::V1::Posts::Serializers::Show },
                 options: { current_user: }
      end

      def like
        endpoint operation: Api::V1::Posts::Operations::Like,
                 renderer_options: { serializer: Api::V1::Posts::Serializers::Show },
                 options: { current_user: }
      end

    end
  end
end
