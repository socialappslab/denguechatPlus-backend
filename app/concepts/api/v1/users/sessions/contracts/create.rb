# frozen_string_literal: true

module Api
  module V1
    module Users
      module Sessions
        module Contracts
          class Create < ApplicationReformContract
            property :email, virtual: true
            property :password, virtual: true

            validation do
              params do
                required(:email).filled(:string)
                required(:password).filled(:string)
              end
            end
          end
        end
      end
    end
  end
end
