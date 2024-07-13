# frozen_string_literal: true

module Api
  module V1
    class RolesController < AuthorizedApiController

      def index
        endpoint operation: Api::V1::Roles::Operations::Index,
                 renderer_options: {
                   serializer: Api::V1::Roles::Serializers::Index
                 }
      end

    end
  end
end
