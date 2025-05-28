# frozen_string_literal: true

module Api
  module V1
    class CitiesController < AuthorizedApiController
      skip_before_action :check_permissions!,
                         only: %i[show_by_country_and_state_assumption list_by_country_and_state_assumption]
      skip_before_action :authorize_access_request!,
                         only: %i[show_by_country_and_state_assumption list_by_country_and_state_assumption]
      def index
        endpoint operation: Api::V1::Cities::Operations::Index,
                 renderer_options: { serializer: Api::V1::Cities::Serializers::Index },
                 options: { current_user: }
      end

      def list_by_country_and_state_assumption
        endpoint operation: Api::V1::Cities::Operations::ListByCountryAndStateAssumption,
                 renderer_options: { serializer: Api::V1::Cities::Serializers::ListByCountryAndStateAssumption },
                 options: { current_user: }
      end

      def show_by_country_and_state_assumption
        endpoint operation: Api::V1::Cities::Operations::Show,
                 renderer_options: { serializer: Api::V1::Cities::Serializers::ShowWithoutNeighborhoods },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::Cities::Operations::Show,
                 renderer_options: { serializer: Api::V1::Cities::Serializers::Show },
                 options: { current_user: }
      end

      def create
        endpoint operation: Api::V1::Cities::Operations::Create,
                 renderer_options: { serializer: Api::V1::Cities::Serializers::Show },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::Cities::Operations::Update,
                 renderer_options: { serializer: Api::V1::Cities::Serializers::Show },
                 options: { current_user: }
      end

      def destroy
        endpoint operation: Api::V1::Cities::Operations::Destroy,
                 options: { current_user: }
      end
    end
  end
end
