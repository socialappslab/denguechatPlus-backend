# frozen_string_literal: true

module Api
  module V1
    class RolesController < AuthorizedApiController

      def index
        endpoint operation: Api::V1::Roles::Operations::Index,
                 renderer_options: {
                   serializer: Api::V1::Roles::Serializers::Index
                 },
                 options: { current_user: }
      end

      def create
        endpoint operation: Api::V1::Roles::Operations::Create,
                 renderer_options: {
                   serializer: Api::V1::Roles::Serializers::Create
                 },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::Roles::Operations::Update,
                 renderer_options: {
                   serializer: Api::V1::Roles::Serializers::Update
                 },
                 options: { current_user: }
      end

    end
  end
end
