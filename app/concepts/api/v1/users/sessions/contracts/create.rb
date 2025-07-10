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
              optional(:password).filled(:string)
              required(:type).filled(:string, included_in?: %w[phone username sms])
            end

            rule(:phone) do |_type, _phone|
              if (values[:type].eql?('phone') || values[:type].eql?('sms')) && values[:phone].nil?
                key(:type).failure(text: :user_credential_requirement, predicate: :filled?)
              end
            end

            rule(:password) do |_type, _password|
              if (values[:type].eql?('phone') || values[:type].eql?('username')) && values[:password].nil?
                key(:type).failure(text: :user_credential_requirement, predicate: :filled?)
              end
            end

            rule(:username) do |_type, _username|
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
