# frozen_string_literal: true

module ApiDoc
  module V1
    module Organization
      extend ::Dox::DSL::Syntax

      ENDPOINT = '/organizations'

      document :api do
        resource 'Organizations' do
          endpoint ENDPOINT
          group 'Organizations'
        end
      end

      document :index do
        action 'View the list of all organizations' do
          path "#{ENDPOINT}{?page}{?filter}"
          params(
            **jsonapi_pagination,

            **json_filter(
              name: 'name'
            )
          )
        end
      end

      document :show do
        action 'Show organization' do
          path "#{ENDPOINT}{?include}"
        end
      end

      document :create do
        action 'Create a organization' do
          params(
            name: {
              type: :string,
              required: :required,
              value: 'Tariki'
            }
          )
        end
      end

      document :update do
        action 'Update a organization' do
          params(
            name: {
              type: :string,
              required: :required,
              value: 'Tariki 2'
            }
          )
        end
      end

      document :delete do
        action 'Remove organization/s'
      end
    end
  end
end
