# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class Index < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end
            params do
              optional(:filter).maybe(:hash) do
                optional(:first_name).maybe(:string)
                optional(:last_name).maybe(:string)
                optional(:full_name).maybe(:string)
                optional(:phone).maybe(:string)
                optional(:email).maybe(:string)
                optional(:username).maybe(:string)
                optional(:status).maybe(:array)
                optional(:role_name).maybe(:string)
                optional(:team_id).maybe(:integer)
              end

              optional(:page).maybe(:hash) do
                optional(:is_cursor).maybe(:bool)
              end

              optional(:sort).maybe(:string)
              optional(:order).maybe(:string, included_in?: %w[asc desc])
              optional(:sort).maybe(:string, included_in?: Constants::User::FILTERS)
            end
            rule(:filter) do |status|
              if value && value[:status] && !value[:status].empty?
                available_status = Constants::User::STATUS
                if (value[:status] & available_status).empty?
                  key(:status).failure(text: "you need choose some of them: #{available_status.join(', ')}",  predicate: :includes?)
                end
              end
            end
          end
        end
      end
    end
  end
end
