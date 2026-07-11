# frozen_string_literal: true

module Api
  module V1
    class HouseBlocksController < ApiController
      before_action :authorize_access_request!, only: %i[update]
      before_action :check_permissions!, only: %i[update]

      def index
        current_user ||= nil
        endpoint operation: Api::V1::HouseBlocks::Operations::Index,
                 renderer_options: {
                   serializer: Api::V1::HouseBlocks::Serializers::Index
                 },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::HouseBlocks::Operations::Update,
                 renderer_options: {
                   serializer: Api::V1::HouseBlocks::Serializers::Show
                 },
                 options: { current_user: }
      end
    end
  end
end
