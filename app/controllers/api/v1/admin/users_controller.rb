# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < ApiController

        def change_status
          endpoint operation: Api::V1::Users::Accounts::Operations::ChangeStatus,
                   renderer_options: { serializer: Api::V1::Users::Accounts::Serializers::UserAccount }
        end
      end
    end
  end
end
