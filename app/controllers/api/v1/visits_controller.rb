# frozen_string_literal: true

module Api
  module V1
    class VisitsController < AuthorizedApiController
      before_action :set_paper_trail_whodunnit, only: %i[update]

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
                 renderer_options: { serializer: Api::V1::Visits::Serializers::ShowAttrsByUpdate },
                 options: { current_user: }
      end

      def inspections
        endpoint operation: Api::V1::Visits::Operations::ShowInspection,
                 renderer_options: { serializer: Api::V1::Visits::Serializers::ShowInspection },
                 options: { current_user: }
      end

      def download_information
        endpoint operation: Api::V1::Visits::Operations::DownloadCsv,
                 options: { current_user: }
      end

      def destroy
        endpoint operation: Api::V1::Visits::Operations::Destroy,
                 options: { current_user: }
      end

      def bulk_upload
        endpoint operation: Api::V1::Visits::Operations::BulkUpload,
                 renderer_options: { serializer: Api::V1::Visits::Serializers::BulkUpload },
                 options: { current_user: }
      end

      private

      def set_paper_trail_whodunnit
        PaperTrail.request.whodunnit = {
          id: current_user&.id,
          full_name: current_user&.full_name
        }.to_json
      end
    end
  end
end
