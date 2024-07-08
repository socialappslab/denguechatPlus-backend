# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class Token < ApplicationReformContract
            property :token, virtual: true

            validation do
              params do
                required(:token).filled(:string)
              end
            end
          end
        end
      end
    end
  end
end
