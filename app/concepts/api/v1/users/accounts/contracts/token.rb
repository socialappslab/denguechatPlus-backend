# frozen_string_literal: true

module Api::V1::Users::Accounts::Contracts
  class Token < ApplicationReformContract
    property :token, virtual: true

    validation do
      params do
        required(:token).filled(:string)
      end
    end
  end
end
