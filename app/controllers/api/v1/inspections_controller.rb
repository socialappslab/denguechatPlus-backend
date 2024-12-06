module Api
  module V1
    class InspectionsController < AuthorizedApiController
      def index
        endpoint operation: Api::V1::Inspections::Operations::Index,
                 renderer_options: { serializer: Api::V1::Comments::Serializers::Index },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::Inspections::Operations::Show,
                 renderer_options: { serializer: Api::V1::Comments::Serializers::Show },
                 options: { current_user: }
      end

      def create
        endpoint operation: Api::V1::Inspections::Operations::Create,
                 renderer_options: { serializer: Api::V1::Comments::Serializers::Show },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::Inspections::Operations::Update,
                 renderer_options: { serializer: Api::V1::Comments::Serializers::Show },
                 options: { current_user: }
      end

      def destroy
        endpoint operation: Api::V1::Inspections::Operations::Destroy,
                 options: { current_user: }
      end
    end
  end
end
