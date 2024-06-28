# frozen_string_literal: true

RSpec.describe 'ApiDoc::V1::Users::Account::Api', :dox do
  include ApiDoc::V1::Users::Account::Api

  describe 'POST #create' do
    include ApiDoc::V1::Users::Account::Create

    let(:user_profile_attrs) { attributes_for(:user_account) }
    let(:email) { user_profile_attrs[:email] }
    let(:password) { user_profile_attrs[:password] }
    let(:redirect_to) { '/redirect_to' }
    let(:params) do
      {
        email:,
        password:,
        redirect_to:
      }
    end
    let(:base_path) { '/api/v1' }

    describe 'Success' do
      before do
        post "#{base_path}/users/accounts", params:, headers:
      end

      it 'creates new user account' do
        expect(response).to match_json_schema('users/accounts/create')
        expect(response).to match_resource_type('user-account')
        expect(response).to be_created
      end
    end

    describe 'Failure' do
      context 'when email is already used' do
        let(:user_account) { create(:user_account, :with_profile, email:) }

        before do
          user_account
          post "#{base_path}/users/accounts", params:, headers:
        end

        include_examples 'renders errors'
      end

      context 'when empty params' do
        let(:params) { {} }

        before do
          post "#{base_path}/users/accounts", params:, headers:
        end

        include_examples 'renders errors'
      end
    end
  end
end
