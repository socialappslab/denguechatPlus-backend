# frozen_string_literal: true

RSpec.describe Api::V1::Users::Sessions::Operations::Destroy do
  subject(:result) do
    described_class.call(
      params: {},
      found_token: refresh_token,
      current_user:,
      flush_session: flush_session_service
    )
  end

  let(:current_user) { user_account }
  let(:user_account) { create(:user_account, :with_profile) }
  let(:user_account_id) { user_account.id }
  let(:refresh_token) do
    JWTSessions::Session.new(
      payload: { account_id: user_account.id, app: 'dengue_chat_plus', verify_aud: true },
      refresh_payload: { account_id: user_account.id, app: 'dengue_chat_plus', verify_aud: true }
    ).login[:refresh]
  end
  let(:flush_session_service) { nil }

  describe 'Success' do
    it 'refreshes session auth token' do
      result = Api::V1::Lib::Services::Sessions::FlushSessionByToken.call(refresh_token, user_account)
      expect(result).to include(
        csrf: a_kind_of(String), access_expiration: a_kind_of(Numeric),
        access_uid: a_kind_of(String), expiration: a_kind_of(Numeric)
      )
    end
  end

  describe 'Failure' do
    shared_examples 'not refreshes session auth token' do
      it 'not refreshes session auth token' do
        expect(result.failure[:type]).to eq(:gone)
        expect(result).to be_failure
      end
    end

    context 'when current user not found' do
      let(:current_user) { nil }

      it_behaves_like 'not refreshes session auth token'
    end
  end
end
