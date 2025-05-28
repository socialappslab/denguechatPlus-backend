# frozen_string_literal: true

RSpec.describe Api::V1::Users::Accounts::Operations::Confirm do
  subject(:result) { described_class.call(params:) }

  let(:user_profile) do
    create(:user_profile,
           :with_account)
  end
  let(:user_account) { user_profile.user_account }
  let(:params) { { token: jwt_token } }
  let(:jwt_token) { create_jwt_token(aud: 'confirm-user-account', sub: user_account.id) }
  let(:redis_key) { "confirm-user-account-#{user_account.id}" }

  before do
    mock_redis.mapped_hmset(redis_key, 'token' => jwt_token)
  end

  describe 'Success' do
    let(:user_payload) do
      {
        account_id: user_account.id,
        app: 'dengue_chat_plus',
        verify_aud: true
      }
    end
    let(:payload) do
      {
        payload: user_payload,
        refresh_payload: user_payload,
        access_exp: 10.minutes.to_i,
        refresh_exp: 9.hours.to_i
      }
    end
    let(:jwt_sessions) { instance_double(JWTSessions::Session) }
    let(:mocked_tokens) { { token: FFaker::Internet.password } }

    it 'confirms user account' do
      expect { result }.to change { mock_redis.hgetall(redis_key) }
        .from('token' => jwt_token).to({})

      expect(user_account.reload.confirmed_at).to be_present
      expect(result).to be_success
    end

    it 'creates tokens for login' do
      expect(JWTSessions::Session).to receive(:new).with(payload) { jwt_sessions }
      expect(jwt_sessions).to receive(:login).and_return(mocked_tokens)
      expect(result.success.dig(:ctx, :user_account)).to eq(user_account)
      expect(result.success.dig(:ctx, :tokens)).to eq(mocked_tokens)
      expect(result).to be_success
    end
  end

  describe 'Failure' do
    context 'with empty params' do
      let(:params) { {} }
      let(:errors) { { token: ['must be filled'] } }

      include_examples 'has validation errors'
    end

    context 'when token contains wrong user_id' do
      let(:jwt_token) { create_jwt_token(aud: 'confirm-user-account', sub: '0') }

      it { expect(result).to be_failure }
    end

    context 'when token does not exists in redis store' do
      let(:jwt_token) { nil }

      it { expect(result).to be_failure }
    end

    context 'when token from params and token in redis store does not equal' do
      let(:params) do
        { token: create_jwt_token(aud: 'confirm-user-account', sub: user_account.id, exp: 2.days.after.to_i) }
      end

      it { expect(result).to be_failure }
    end

    context 'when jwt_token expired' do
      let(:jwt_token) { create_jwt_token(aud: 'confirm-user-account', sub: user_account.id, exp: 1.day.ago.to_i) }

      it { expect(result).to be_failure }
    end

    context 'when wrong token' do
      let(:jwt_token) { 'wrong_token' }

      it { expect(result).to be_failure }
    end
  end
end
