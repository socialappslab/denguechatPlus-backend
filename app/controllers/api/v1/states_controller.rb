# frozen_string_literal: true

module Api
  module V1
    class StatesController < AuthorizedApiController

      def index
        endpoint operation: Api::V1::States::Operations::Index,
                 renderer_options: { serializer: Api::V1::States::Serializers::Index },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::States::Operations::Show,
                 renderer_options: { serializer: Api::V1::States::Serializers::Show },
                 options: { current_user: }
      end

      def create
        endpoint operation: Api::V1::States::Operations::Create,
                 renderer_options: { serializer: Api::V1::States::Serializers::Show },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::States::Operations::Update,
                 renderer_options: { serializer: Api::V1::States::Serializers::Show },
                 options: { current_user: }
      end

      def destroy
        endpoint operation: Api::V1::States::Operations::Destroy,
                 options: { current_user: }
      end

    end
  end
end
