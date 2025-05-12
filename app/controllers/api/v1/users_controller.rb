# frozen_string_literal: true

module Api
  module V1
    class UsersController < AuthorizedApiController
      skip_before_action :check_permissions!, only: %i[show_current_user]
      skip_before_action :authorize_access_request!, only: %i[show_current_user]

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
                 options: { current_user:, source: request.headers['X-Client-Device'] }
      end

      def delete_account
        endpoint operation: Api::V1::Users::Accounts::Operations::Destroy,
                 options: { current_user: }
      end

      def show_current_user
        endpoint operation: Api::V1::Users::Accounts::Operations::ShowCurrentUser,
                 renderer_options: {
                   serializer: Api::V1::Users::Accounts::Serializers::ShowCurrentUser
                 },
                 options: { current_user: }
      end

      def change_status
        endpoint operation: Api::V1::Users::Accounts::Operations::ChangeStatus,
                 renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::UserAccount },
                 options: {  found_token:, current_user: }
      end

      def change_house_blocks
        endpoint operation: Api::V1::Users::Accounts::Operations::ChangeHouseBlock,
                 renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::Show },
                 options: {  found_token:, current_user: }
      end

      def change_team
        endpoint operation: Api::V1::Users::Accounts::Operations::ChangeTeam,
                 renderer_options: {
                   serializer: Api::V1::Users::Accounts::Serializers::ShowCurrentUser
                 },
                 options: { current_user: }
      end

      def update_password
        endpoint operation: Api::V1::Users::Accounts::Operations::UpdatePassword,
                 renderer_options: {
                   serializer: Api::V1::Users::Accounts::Serializers::ShowCurrentUser
                 },
                 options: { current_user: }
      end

    end
  end
end
