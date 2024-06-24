# frozen_string_literal: true

RSpec.describe Api::V1::Users::Sessions::Operations::Create do
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
        user_account_id: user_account.id,
        verify_aud: true
      }
    end
    let(:payload) do
      {
        payload: user_payload,
        refresh_payload: user_payload,
        namespace: "user-account-#{user_account.id}",
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

        expect(result[:model]).to eq(user_profile)
        expect(result[:tokens]).to eq(mocked_tokens)
        expect(result).to be_success
      end
    end

    include_examples 'creates tokens for login'

    context 'when user was deactivated by them own' do
      let(:user_account) do
        create(:user_account,
               :with_profile,
               :deactivated)
      end

      include_examples 'creates tokens for login'

      it 'undiscards account' do
        expect { result }.to change { user_account.reload.discarded? }.from(true).to(false)
      end
    end

    context 'when user account was not confirmed' do
      let(:confirmed_at) { nil }
      let(:audience) { Constants::User::NON_CONFIRMED_user_AUD }

      include_examples 'creates tokens for login'
    end

    context 'when user account email is not in lower case' do
      let(:upcase_email) { 'UPCASE@EMAIL.COM' }
      let(:user_account) do
        create(
          :user_account,
          :with_profile,
          confirmed_at:,
          email: upcase_email
        )
      end
      let(:params) do
        {
          email: user_account.email.downcase,
          password:
        }
      end

      it 'finds user account anyway' do
        expect(result[:model].user_account).to eq(user_account)
      end
    end

    context 'when email in params is in upcase, while email in DB is not' do
      let(:params) do
        {
          email: user_account.email.upcase,
          password:
        }
      end

      it 'finds user account anyway' do
        expect(result[:model].user_account).to eq(user_account)
      end
    end
  end

  describe 'Failure' do
    context 'with empty keys' do
      let(:params) { {} }
      let(:errors) do
        {
          email: ['must be filled'],
          password: ['must be filled']
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

      include_examples 'has validation errors'
    end

    context 'when user does not exist' do
      let(:params) do
        {
          email: 'email@example.com',
          password:
        }
      end
      let(:errors) { { base: ['Wrong credentials'] } }

      include_examples 'has validation errors'
    end
  end
end
