# frozen_string_literal: true

module Api
  module V1
    class SpecialPlacesController < AuthorizedApiController
      def index
        endpoint operation: Api::V1::SpecialPlaces::Operations::Index,
                 renderer_options: { serializer: Api::V1::SpecialPlaces::Serializers::Index }
      end

      def show
        endpoint operation: Api::V1::SpecialPlaces::Operations::Show,
                 renderer_options: { serializer: Api::V1::SpecialPlaces::Serializers::Index }
      end

      def create
        endpoint operation: Api::V1::SpecialPlaces::Operations::Create,
                 renderer_options: { serializer: Api::V1::SpecialPlaces::Serializers::Show },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::SpecialPlaces::Operations::Update,
                 renderer_options: { serializer: Api::V1::SpecialPlaces::Serializers::Show },
                 options: { current_user: }
      end

      def destroy
        endpoint operation: Api::V1::SpecialPlaces::Operations::Destroy,
                 options: { current_user: }
      end
    end
  end
end
