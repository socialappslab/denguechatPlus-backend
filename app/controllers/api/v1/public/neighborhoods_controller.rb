# frozen_string_literal: true

module Api
  module V1
    module Public
      class NeighborhoodsController < ApiController

        def index
          endpoint operation: Api::V1::Neighborhoods::Operations::Index,
                   renderer_options: { serializer: Api::V1::Neighborhoods::Serializers::Index }
        end

        def show
          endpoint operation: Api::V1::Neighborhoods::Operations::Show,
                   renderer_options: { serializer: Api::V1::Neighborhoods::Serializers::Show }
        end

      end
    end
  end
end
