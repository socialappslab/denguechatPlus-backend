# frozen_string_literal: true

module Api
  module V1
    class WedgesController < AuthorizedApiController
      skip_before_action :check_permissions!, only: %i[index]
      skip_before_action :authorize_access_request!, only: %i[show]
      def index
        endpoint operation: Api::V1::Wedges::Operations::Index,
                 renderer_options: { serializer: Api::V1::Wedges::Serializers::Index }
      end

      def show
        endpoint operation: Api::V1::Wedges::Operations::Show,
                 renderer_options: { serializer: Api::V1::Wedges::Serializers::Show }
      end

    end
  end
end
