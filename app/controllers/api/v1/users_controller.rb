# frozen_string_literal: true

module Api
  module V1
    class UsersController < AuthorizedApiController

      def index
        endpoint operation: Api::V1::Users::Accounts::Operations::Index,
                 renderer_options: {
                   serializer: Api::V1::Users::Accounts::Serializers::Index
                 },
                 options: { current_user: }
      end

      def show
        endpoint operation: Api::V1::Users::Accounts::Operations::Show,
                 renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::Show },
                 options: { current_user: }
      end

      def update
        endpoint operation: Api::V1::Users::Accounts::Operations::Update,
                 renderer_options: {
                   serializer: Api::V1::Users::Accounts::Serializers::ShowCurrentUser
                 },
                 options: { current_user: }
      end

      def show_current_user
        endpoint operation: Api::V1::Users::Accounts::Operations::ShowCurrentUser,
                 renderer_options: {
                   serializer: Api::V1::Users::Accounts::Serializers::ShowCurrentUser
                 },
                 options: { current_user: }
      end

      def change_team
        endpoint operation: Api::V1::Users::Accounts::Operations::ChangeTeam,
                 renderer_options: {
                   serializer: Api::V1::Users::Accounts::Serializers::ShowCurrentUser
                 },
                 options: { current_user: }
      end

    end
  end
end
