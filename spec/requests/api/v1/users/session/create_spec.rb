# frozen_string_literal: true

RSpec.describe 'Api::V1::Users::Sessions', :dox do
  include ApiDoc::V1::Users::Session::Api

  let(:password) { 'Password1!' }
  let(:user_profile) do
    create(:user_profile, :with_account, password:)
  end
  let(:user_account) { user_profile.user_account }
  let(:base_path) { '/api/v1' }

  shared_examples 'renders unauthenticated error' do
    it 'renders unauthenticated error' do
      expect(response).to be_unauthorized
      expect(response).to match_json_schema('errors')
    end
  end

  describe 'POST #create' do
    include ApiDoc::V1::Users::Session::Create

    let(:params) do
      {
        email: user_account.email,
        password:
      }
    end

    before do
      post "#{base_path}/users/session", params:, as: :json
    end

    describe 'Success' do
      it 'renders user whose session was created' do
        expect(response).to match_json_schema('users/sessions/create')
        expect(response).to match_resource_type('userProfile')
        expect(response).to be_created
      end
    end

    describe 'Failure' do
      context 'when credential are wrong' do
        let(:params) do
          {
            email: user_account.email,
            password: 'password'
          }
        end

        it_behaves_like 'renders unauthenticated error'
      end
    end
  end

  describe 'DELETE #destroy' do
    include ApiDoc::V1::Users::Session::Destroy

    let(:unexpected_action) { nil }
    let(:refresh_token) do
      JWTSessions.access_exp_time = 3600
      JWTSessions::Session.new(
        access_claims: { exp: Time.now.to_i },
        payload: { user_account_id: user_account.id },
        refresh_payload: { 'user_account_id' => user_account.id },
        namespace: "user-account-#{user_account.id}"
      ).login[:refresh]
    end
    let(:headers) { { 'X-Refresh-Token': refresh_token } }

    before do
      unexpected_action
      delete "#{base_path}/users/session", headers:, as: :json
    end

    describe 'Success' do
      it 'flushes token' do
        expect([410, 214].include?(response.status)).to be true
        expect(response.body).to be_empty
      end
    end

    describe 'Failure' do
      context 'when wrong token' do
        let(:headers) { { 'X-Refresh-Token': 'wrong_token' } }

        it_behaves_like 'renders unauthenticated error'
      end

      context 'when refresh token not found' do
        let(:unexpected_action) do
          allow(Api::V1::Lib::Services::Sessions::FlushSessionByToken)
            .to receive(:call).and_return(false)
        end

        it 'returns gone status' do
          expect(response.body).to be_empty
          expect(response).to have_http_status(:gone)
        end
      end
    end
  end
end
