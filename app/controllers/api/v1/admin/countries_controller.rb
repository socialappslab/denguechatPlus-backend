# frozen_string_literal: true

module Api
  module V1
    module Admin
      class CountriesController < AuthorizedApiController

        def index
          endpoint operation: Api::V1::Countries::Operations::Index,
                   renderer_options: { serializer: Api::V1::Countries::Serializers::Index },
                   options: { current_user: }
        end

        def show
          endpoint operation: Api::V1::Countries::Operations::Show,
                   renderer_options: { serializer: Api::V1::Countries::Serializers::Show },
                   options: { current_user: }
        end

        def create
          endpoint operation: Api::V1::Countries::Operations::Create,
                   renderer_options: { serializer: Api::V1::Countries::Serializers::Show },
                   options: { current_user: }
        end

        def update
          endpoint operation: Api::V1::Countries::Operations::Update,
                   renderer_options: { serializer: Api::V1::Countries::Serializers::Show },
                   options: { current_user: }
        end

        def destroy
          endpoint operation: Api::V1::Countries::Operations::Destroy,
                   options: { current_user: }
        end

      end
    end
  end
end
