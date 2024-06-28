# frozen_string_literal: true

RSpec.describe Api::V1::Users::Accounts::Operations::Create do
  subject(:result) { described_class.call(params:) }

  let(:password) { attributes_for(:user_account)[:password] }
  let(:confirmed_at) { Time.current }
  let(:user_account) { create(:user_account, :with_profile, confirmed_at:) }
  let(:user_profile) { user_account.user_profile }
  let(:params) do
    {
      email: user_account.email,
      password:
    }
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

    shared_examples 'creates tokens for login' do
      it 'creates tokens for login' do
        expect(JWTSessions::Session).to receive(:new).with(payload) { jwt_sessions }
        expect(jwt_sessions).to receive(:login).and_return(mocked_tokens)
        expect(result.success.dig(:ctx, :model)).to eq(user_account)
        expect(result.success.dig(:ctx, :tokens)).to eq(mocked_tokens)
        expect(result).to be_success
      end
    end

    context 'when user account was not confirmed' do
      let(:user_account) do
        create(:user_account,
               :with_profile,
               :without_confirmation)
      end

      it 'confirmed_at have to be nil' do
        expect(user_account).not_to be_confirmed_at
      end
    end
  end

  describe 'Failure' do
    context 'with empty keys' do
      let(:params) { {} }
      let(:errors) do
        {
          email: ['must be filled'],
          password: ['must be filled', 'size cannot be less than 8']
        }
      end

      include_examples 'has validation errors'
    end

    context 'when password is invalid' do
      let(:params) do
        {
          email: user_account.email,
          password: 'password'
        }
      end
      let(:errors) { { base: ['Wrong credentials'] } }
    end

    context 'when user does not exist' do
      let(:params) do
        {
          email: 'email@example.com',
          password:
        }
      end
      let(:errors) { { base: ['Wrong credentials'] } }
    end
  end
end
