# frozen_string_literal: true

module Api
  module V1
    class QuestionnairesController < AuthorizedApiController
      def current
        endpoint operation: Api::V1::Questionnaires::Operations::Current,
                 renderer_options: { serializer: Api::V1::Questionnaires::Serializers::Show }
      end
    end
  end
end
