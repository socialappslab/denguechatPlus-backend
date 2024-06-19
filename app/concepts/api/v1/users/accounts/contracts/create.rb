# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class Create < ApplicationReformContract
            property :email, virtual: true, reader: ->(doc:, **) { doc['email']&.downcase }
            property :password, virtual: true

            validation do
              params do
                required(:email).filled(:string)
                required(:password).filled(:string, min_size?: Constants::User::PASSWORD_MIN_LENGTH)
              end

              # rule(:email).validate(:email_regex?)

              # rule(:email) do
              #   next if rule_error?
              #
              #   key.failure(:user_email_unique?) if UserAccount.exists?(['LOWER(email) = LOWER(?)', value])
              # end
            end
          end
        end
      end
    end
  end
end
