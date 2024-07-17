# frozen_string_literal: true

module Api
  module V1
    class RolesController < ApiController

      def index
        endpoint operation: Api::V1::Roles::Operations::Index,
                 renderer_options: {
                   serializer: Api::V1::Roles::Serializers::Index
                 }
      end

      def update
        endpoint operation: Api::V1::Roles::Operations::Update,
                 renderer_options: {
                   serializer: Api::V1::Roles::Serializers::Update
                 }
      end

    end
  end
end
