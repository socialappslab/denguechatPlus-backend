# frozen_string_literal: true

module Api
  module V1
    class PermissionsController < AuthorizedApiController
      def index
        endpoint operation: Api::V1::Permissions::Operations::Index,
                 renderer_options: {
                   serializer: Api::V1::Permissions::Serializers::Index
                 },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::Permissions::Operations::Show,
                 renderer_options: {
                   serializer: Api::V1::Permissions::Serializers::Show
                 },
                 options: { current_user: }
      end
    end
  end
end
