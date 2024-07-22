# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < AuthorizedApiController
      def index
        endpoint operation: Api::V1::Organizations::Operations::Index,
                 renderer_options: { serializer: Api::V1::Organizations::Serializers::Index }
      end

      def show
        endpoint operation: Api::V1::Organizations::Operations::Show,
                 renderer_options: { serializer: Api::V1::Organizations::Serializers::Index }
      end

      def create
        endpoint operation: Api::V1::Organizations::Operations::Create,
                 renderer_options: { serializer: Api::V1::Organizations::Serializers::Show },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::Organizations::Operations::Update,
                 renderer_options: { serializer: Api::V1::Organizations::Serializers::Show },
                 options: { current_user: }
      end

      def destroy
        endpoint operation: Api::V1::Organizations::Operations::Destroy,
                 options: { current_user: }
      end
    end
  end
end
