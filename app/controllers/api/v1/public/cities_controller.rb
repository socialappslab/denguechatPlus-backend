# frozen_string_literal: true

module Api
  module V1
    module Public
      class CitiesController < ApiController
        def index
          endpoint operation: Api::V1::Cities::Operations::Index,
                   renderer_options: { serializer: Api::V1::Cities::Serializers::Index }
        end

        def show
          endpoint operation: Api::V1::Cities::Operations::Show,
                   renderer_options: { serializer: Api::V1::Cities::Serializers::Show }
        end
      end
    end
  end
end
