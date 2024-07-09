# frozen_string_literal: true

module Api
  module V1
    module Admin
      class CitiesController < ApiController

        def index
          endpoint operation: Api::V1::Cities::Operations::Index,
                   renderer_options: { serializer: Api::V1::Cities::Serializers::Index },
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
end
