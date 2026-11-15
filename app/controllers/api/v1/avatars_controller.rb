# frozen_string_literal: true

module Api
  module V1
    class AvatarsController < AuthorizedApiController
      def index
        endpoint operation: Api::V1::Avatars::Operations::Index,
                 renderer_options: { serializer: Api::V1::Avatars::Serializers::Index },
                 options: { current_user: }
      end
    end
  end
end
