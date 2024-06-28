# frozen_string_literal: true

module ApiDoc
  module V1
    module Users
      module Session
        extend ::Dox::DSL::Syntax

        document :api do
          resource 'Session' do
            endpoint '/users/session'
            group 'Users'
          end
        end

        document :create do
          action 'Create user session (log in)'
        end

        document :destroy do
          action 'Destroy user session (log out)'
        end
      end
    end
  end
end
