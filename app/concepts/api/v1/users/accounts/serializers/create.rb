# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class Create < ApplicationSerializer
            set_type :user_account

            attributes :email, :confirmed_at
          end
        end
      end
    end
  end
end
