# frozen_string_literal: true

module Api
  module V1
    module Users
      class AccountsController < ApiController
        def create
          endpoint operation: Api::V1::Users::Accounts::Operations::Create,
                   options: { current_user: },
                   renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::Create }
        end

        def confirm_account
          endpoint operation: Api::V1::Users::Accounts::Operations::Confirm,
                   renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::Create }
        end

      end
    end
  end
end
