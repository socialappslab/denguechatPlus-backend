# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Serializers
        class UserProfile < ApplicationSerializer
          set_type :user_account

          attributes :id, :first_name, :last_name
        end
      end
    end
  end
end
