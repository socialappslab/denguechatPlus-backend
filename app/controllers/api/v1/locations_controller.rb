# frozen_string_literal: true

module Api
  module V1
    class LocationsController < ApiController
      def index
        endpoint operation: Api::V1::Locations::Operations::Index,
                 renderer_options: { serializer: Api::V1::Locations::Serializers::IndexSerializer },
                 options: { current_user: }
      end
    end
  end
end
