# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Serializers
        class Member < ApplicationSerializer
          set_type :member_team

          attributes  :first_name, :last_name

        end
      end
    end
  end
end
