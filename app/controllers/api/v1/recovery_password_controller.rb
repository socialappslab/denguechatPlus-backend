# frozen_string_literal: true

module Api
  module V1
    class RecoveryPasswordController < AuthorizedApiController
      skip_before_action :check_permissions!, only: %i[validate_phone validate_code new_password]
      skip_before_action :authorize_access_request!, only: %i[validate_phone validate_code new_password]


      def validate_phone
        endpoint operation: Api::V1::Users::Accounts::Operations::ValidatePhone
      end

      def validate_code
        endpoint operation: Api::V1::Users::Accounts::Operations::ValidateCode,
                 renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::ValidateCode }
      end

      def new_password
        endpoint operation: Api::V1::Users::Accounts::Operations::NewPassword,
                 renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::UserAccount }
      end
    end
  end
end
