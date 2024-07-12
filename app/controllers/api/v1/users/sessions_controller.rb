# frozen_string_literal: true

module Api
  module V1
    module Users
      class SessionsController < ApiController
        before_action :authorize_refresh_request!, only: :refresh_token
        def create
          endpoint operation: Api::V1::Users::Sessions::Operations::Create,
                   renderer_options: {
                     serializer: Api::V1::Users::Sessions::Serializers::Create
                   }
        end

        def refresh_token
          endpoint operation: Api::V1::Users::Sessions::Operations::RefreshToken,
                   renderer_options: {
                     serializer: Api::V1::Users::Sessions::Serializers::Create
                   },
                   options: { found_token:, payload:}
        end

        def destroy
          authorize_refresh_request!
          endpoint operation: Api::V1::Users::Sessions::Operations::Destroy,
                   options: {
                     found_token:,
                     current_user:
                   }
        end
      end
    end
  end
end
