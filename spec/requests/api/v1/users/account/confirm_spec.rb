# frozen_string_literal: true

RSpec.describe 'ApiDoc::V1::Users::Account::Api', :dox do
  include ApiDoc::V1::Users::Account::Api

  let(:current_user) do
    create(:user_profile, :with_account)
  end
  let(:user_account) { current_user.user_account }
  let(:base_path) { '/api/v1' }

  describe 'POST #create' do
    include ApiDoc::V1::Users::Account::Create

    let(:params) do
      {
        token: jwt_token
      }
    end
    let(:new_email) { FFaker::Internet.unique.email }
    let(:jwt_token) { create_jwt_token(aud: 'confirm-user-account', sub: user_account.id) }
    let(:redis_key) { "confirm-user-account-#{user_account.id}" }

    before do
      mock_redis.mapped_hmset(redis_key, 'token' => jwt_token)
      post "#{base_path}/users/accounts/confirm_account", params:
    end

    describe 'Success' do
      it 'confirms user email' do
        expect(response).to be_created
      end
    end

    describe 'Failure' do
      context 'with invalid params data' do
        let(:jwt_token) { 'wrong_token' }

        it 'renders gone response status' do
          expect(response).to have_http_status 422
        end
      end
    end
  end
end
