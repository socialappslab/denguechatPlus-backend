# frozen_string_literal: true

module Api
  module V1
    module Admin
      class TeamsController < AuthorizedApiController

        def index
          endpoint operation: Api::V1::Teams::Operations::Index,
                   renderer_options: { serializer: Api::V1::Teams::Serializers::Index },
                   options: { current_user: }
        end

        def show
          endpoint operation: Api::V1::Teams::Operations::Show,
                   renderer_options: { serializer: Api::V1::Teams::Serializers::Show },
                   options: { current_user: }
        end

        def create
          endpoint operation: Api::V1::Teams::Operations::Create,
                   renderer_options: { serializer: Api::V1::Teams::Serializers::Show },
                   options: { current_user: }
        end

        def update
          endpoint operation: Api::V1::Teams::Operations::Update,
                   renderer_options: { serializer: Api::V1::Teams::Serializers::Show },
                   options: { current_user: }
        end

        def destroy
          endpoint operation: Api::V1::Teams::Operations::Destroy,
                   options: { current_user: }
        end

      end
    end
  end
end
