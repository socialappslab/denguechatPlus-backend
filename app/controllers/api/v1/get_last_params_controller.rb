# frozen_string_literal: true

module Api
  module V1
    class GetLastParamsController < AuthorizedApiController
      def index
        endpoint operation: Api::V1::GetLastParams::Operations::Index,
                 renderer_options: { serializer: Api::V1::GetLastParams::Serializers::Index },
                 options: { current_user: }
      end

    end
  end
end
