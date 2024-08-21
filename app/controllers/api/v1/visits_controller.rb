# frozen_string_literal: true

module Api
  module V1
    class VisitsController < AuthorizedApiController
      def create
        endpoint operation: Api::V1::Visits::Operations::Create,
                 renderer_options: { serializer: Api::V1::Visits::Serializers::Show },
                 options: { current_user: }
      end
    end
  end
end
