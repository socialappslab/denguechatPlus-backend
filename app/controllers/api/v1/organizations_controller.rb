# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < AuthorizedApiController
      def index
        endpoint operation: Api::V1::Organizations::Operations::Index,
                 renderer_options: { serializer: Api::V1::Organizations::Serializers::Index },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::Organizations::Operations::Show,
                 renderer_options: { serializer: Api::V1::Organizations::Serializers::Index },
                 options: { current_user: }
      end
    end
  end
end
