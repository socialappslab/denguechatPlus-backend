# frozen_string_literal: true

RSpec.describe Api::V1::Lib::Services::TokenCreators::ConfirmAccount do
  let(:service) do
    described_class.new(user_account, redis_cache_repo: redis_cache, jwt_adapter:)
  end

  let(:redis_cache) { instance_double(Repository::RedisCache) }
  let(:jwt_adapter) { class_double(Adapter::JWT) }
  let(:token) { 'token' }
  let(:user_account) { build_stubbed(:user_account) }
  let(:jwt_aud) { Constants::Tokens::User::CONFIRM_ACCOUNT_AUD }

  before { freeze_time }

  describe '#call' do
    it 'returns generated token' do
      expect(redis_cache).to receive(:persist).with(
        key: "confirm-user-account-#{user_account.id}",
        payload: { token: },
        exp_at: Constants::Tokens::FIVE_YEARS.from_now.to_i
      )
      expect(jwt_adapter).to receive(:encode)
        .with(sub: user_account.id)
        .and_return(token)

      expect(service.call).to eq(token)
    end
  end
end
