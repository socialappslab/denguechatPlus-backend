# frozen_string_literal: true

module Api
  module V1
    class VisitsController < AuthorizedApiController
      def index
        endpoint operation: Api::V1::Visits::Operations::Index,
                 renderer_options: { serializer: Api::V1::Visits::Serializers::Index },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::Visits::Operations::Show,
                 renderer_options: { serializer: Api::V1::Visits::Serializers::Show },
                 options: { current_user: }
      end

      def create
        endpoint operation: Api::V1::Visits::Operations::Create,
                 renderer_options: { serializer: Api::V1::Visits::Serializers::Show },
                 options: { current_user: }

      end

      def update
        endpoint operation: Api::V1::Visits::Operations::Update,
                 renderer_options: { serializer: Api::V1::Visits::Serializers::Show },
                 options: { current_user: }

      end

      def inspections
        endpoint operation: Api::V1::Visits::Operations::ShowInspection,
                 renderer_options: { serializer: Api::V1::Visits::Serializers::ShowInspection },
                 options: { current_user: }
      end
    end
  end
end
