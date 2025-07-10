# frozen_string_literal: true

module Api
  module V1
    module Public
      class CountriesController < ApiController
        def index
          endpoint operation: Api::V1::Countries::Operations::Index,
                   renderer_options: { serializer: Api::V1::Countries::Serializers::Index }
        end

        def show
          endpoint operation: Api::V1::Countries::Operations::Show,
                   renderer_options: { serializer: Api::V1::Countries::Serializers::Show }
        end
      end
    end
  end
end
