require 'dry/validation/contract'

module Api
  module V1
    module Users
      module Accounts
        module Contracts
          class ChangeStatus < Dry::Validation::Contract
            def self.kall(...)
              new.call(...)
            end

            params do
              required(:id).filled(:integer)
              optional(:locked).maybe(:bool)
              optional(:status).maybe(:bool)
            end

            rule(:locked, :status) do
              if values[:locked].nil? && values[:status].nil?
                key(:id).failure(text: I18n.t('errors.users.status_change.without_params'), predicate: :filled?)
              end
            end

          end
        end
      end
    end
  end
end
