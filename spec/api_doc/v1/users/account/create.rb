# frozen_string_literal: true

module ApiDoc
  module V1
    module Users
      module Account
        extend ::Dox::DSL::Syntax

        document :api do
          resource 'Accounts' do
            endpoint '/accounts'
            group 'Users'
          end
        end

        document :create do
          action 'Create user account (sign up)'
        end

      end
    end
  end
end
