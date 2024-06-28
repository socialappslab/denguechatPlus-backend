# frozen_string_literal: true

module Helpers
  module_function

  def pre_request_actions
    nil
  end

  def decode_payload(token)
    JWT.decode(token, Rails.application.credentials.secret_jwt_encryption_key, true)[0]
  end

  def slice_attrs(object, *attributes_array)
    object.reload.attributes.symbolize_keys.slice(*attributes_array)
  end

  def match_validation_errors(operation_result, error_messages)
    errors = operation_result.failure[:ctx]['errors'] || operation_result.failure[:ctx]['contract.default'].errors.messages
    expect(operation_result).to be_failure
    expect(errors).to match error_messages
  end

  def create_jwt_token(sub: nil, exp: 1.day.from_now.to_i, **options)
    JWT.encode({ sub:, exp: }.merge(options), ENV.fetch('JWT_SECRET_KEY', nil))
  end

  def auth_header(account, audience = nil)
    namespace = Api::V1::Lib::Services::AuthTokenNamespace.call(
      Api::V1::Lib::Services::AuthAccountType.call(account),
      account.id
    )
    "Bearer #{session_tokens(token_payload(account, audience), namespace)[:access]}"
  end

  def create_subscription_payload(user_profile, exp = Constants::Tokens::DEFAULT_EXPIRATION_TIME.from_now.to_i)
    {
      aud: Constants::WebSocket::AUD_PREFIX,
      profile_id: user_profile.id,
      profile_type: user_profile.class.name,
      exp:,
      uuid: 'uuid'
    }
  end

  def broadcasted_message(stream, index = 0)
    ::ActionCable.server.pubsub.broadcasts(stream)[index]
  end

  def session_tokens(payload, namespace)
    JWTSessions::Session.new(payload:, refresh_payload: payload, namespace:).login
  end

  def token_payload(account, audience)
    account_id = account.id
    { user_account_id: account_id, aud: audience, verify_aud: true }
  end

  def mock_redis
    Container['adapters.redis']
  end

  def expect_notifier(who, to_receive:, with: nil, receive_times: 1)
    mailer_double = double(who) # rubocop:disable RSpec/VerifiedDoubles
    if with
      expect(who).to receive(to_receive).exactly(receive_times).times.with(*with).and_return(mailer_double)
    else
      expect(who).to receive(to_receive).exactly(receive_times).times.and_return(mailer_double)
    end
    expect(mailer_double).to receive(:deliver_later).exactly(receive_times).times.with(no_args).and_return(true)
  end
end
