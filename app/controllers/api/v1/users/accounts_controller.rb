# frozen_string_literal: true

module Api
  module V1
    module Users
      class AccountsController < AuthorizedApiController
        def create
          endpoint operation: Api::V1::Users::Accounts::Operations::Create,
                   options: { current_user: },
                   renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::UserAccount }
        end

        def confirm_account
          endpoint operation: Api::V1::Users::Accounts::Operations::Confirm,
                   renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::UserAccount },
                   options: { current_user: }
        end
      end
    end
  end
end
