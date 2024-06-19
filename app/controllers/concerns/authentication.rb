# frozen_string_literal: true

module Authentication
  def self.included(base)
    base.class_eval do
      include JWTSessions::RailsAuthorization

      rescue_from JWTSessions::Errors::Unauthorized do
        exception_response(:unauthorized, I18n.t('errors.unauthenticated'))
      end

      rescue_from ActiveRecord::RecordNotFound do
        exception_response(:not_found, I18n.t('errors.not_found'))
      end
    end
  end

  def current_user
    @current_user ||= UserAccount.find_by(id: payload['user_account_id'])
  end

  private

  def exception_response(message, status = :unprocessable_entity)
    errors = [{ field: :base, messages: [message] }]

    render Services::ComposeRenderHash.call(
      result: { model: errors },
      serializer: Api::V1::Lib::Serializers::Errors::Hash,
      status:
    )
  end
end
