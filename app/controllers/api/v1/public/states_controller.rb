# frozen_string_literal: true

module Api
  module V1
    module Public
      class StatesController < ApiController
        def index
          endpoint operation: Api::V1::States::Operations::Index,
                   renderer_options: { serializer: Api::V1::States::Serializers::Index }
        end

        def show
          endpoint operation: Api::V1::States::Operations::Show,
                   renderer_options: { serializer: Api::V1::States::Serializers::Show }
        end
      end
    end
  end
end
