# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class City < ApplicationSerializer
            set_type :city

            attributes :name
          end
        end
      end
    end
  end
end
