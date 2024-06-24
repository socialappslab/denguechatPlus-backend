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
      payload: { user_account_id: },
      refresh_payload: { user_account_id: },
      namespace: "user-account-#{user_account_id}"
    ).login[:refresh]
  end
  let(:flush_session_service) { nil }

  describe 'Success' do
    it 'refreshes session auth token' do
      expect(Api::V1::Lib::Services::Sessions::FlushSessionByToken)
        .to receive(:call).with(refresh_token, user_account).and_call_original
      expect(result).to be_success
    end
  end

  describe 'Failure' do
    shared_examples 'not refreshes session auth token' do
      it 'not refreshes session auth token' do
        expect(result[:failure_semantic]).to eq(:gone)
        expect(result).to be_failure
      end
    end

    context 'when current user not found' do
      let(:current_user) { nil }

      include_examples 'not refreshes session auth token'
    end

    context 'when refresh token not found' do
      let(:flush_session_service) { class_double(Api::V1::Lib::Services::Sessions::FlushSessionByToken) }

      before { allow(flush_session_service).to receive(:call).and_return(false) }

      include_examples 'not refreshes session auth token'
    end
  end
end
