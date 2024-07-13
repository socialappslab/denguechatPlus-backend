# frozen_string_literal: true

module Api
  module V1
    class UsersController < AuthorizedApiController

      def index
        endpoint operation: Api::V1::Users::Accounts::Operations::Index,
                 renderer_options: {
                   serializer: Api::V1::Users::Accounts::Serializers::Index
                 }
      end

    end
  end
end
