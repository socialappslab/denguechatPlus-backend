# frozen_string_literal: true

module Api
  module V1
    module Users
      module Sessions
        module Contracts
          class Create < Dry::Validation::Contract

            def self.kall(...)
              new.call(...)
            end

            params do
              optional(:phone).filled(:string)
              optional(:username).filled(:string)
              required(:password).filled(:string)
              required(:type).filled(:string, included_in?: %w[phone username])
            end

            rule(:phone) do |type, phone|
              if values[:type].eql?('phone') && values[:phone].nil?
                key(:type).failure(text: :user_credential_requirement, predicate: :filled?)
              end
            end

            rule( :username) do |type, username|
              if values[:type].eql?('username') && values[:username].nil?
                key(:username).failure(text: :user_credential_requirement?, predicate: :filled?)
              end
            end

          end
        end
      end
    end
  end
end
