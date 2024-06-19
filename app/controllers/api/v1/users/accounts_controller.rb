# frozen_string_literal: true

module Api
  module V1
    module Users
      class AccountsController < ApiController
        def create
          endpoint operation: Api::V1::Users::Accounts::Operations::Create,
                   options: { current_user: }
        end

        def confirm_account
          endpoint operation: Api::V1::Users::Accounts::Operations::Confirm,
                   renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::Create }
        end

        # def destroy
        #   authorize_refresh_request!
        #   endpoint operation: Api::V1::Users::Accounts::Operations::Destroy,
        #            options: {
        #              found_token:,
        #              current_user:
        #            }
        # end
      end
    end
  end
end
