# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < AuthorizedApiController

        def change_status
          endpoint operation: Api::V1::Users::Accounts::Operations::ChangeStatus,
                   renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::UserAccount },
                   options: { current_user: }
        end
      end
    end
  end
end
