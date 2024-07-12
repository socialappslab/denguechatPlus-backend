# frozen_string_literal: true

module Authentication
  def self.included(base)
    base.class_eval do
      include JWTSessions::RailsAuthorization

      rescue_from JWTSessions::Errors::Unauthorized do
        exception_response(I18n.t('errors.unauthorized'), :unauthorized)
      end

      rescue_from JWTSessions::Errors::InvalidPayload do
        exception_response(I18n.t('errors.unauthorized'), :unauthorized, :invalid_payload)
      end

      rescue_from JWTSessions::Errors::Malconfigured do
        exception_response(I18n.t('errors.unauthorized'), :unauthorized, :malconfigured)
      end

      rescue_from JWTSessions::Errors::Error do
        exception_response(I18n.t('errors.invalid_token'), :unauthorized, :invalid_token)
      end

      rescue_from JWTSessions::Errors::Expired do
        exception_response(I18n.t('errors.expired_token'), :unauthorized, :expired_token)
      end

      rescue_from ActiveRecord::RecordNotFound do
        exception_response( I18n.t('errors.not_found'), :unauthorized, :not_found)
      end
    end
  end

  def current_user
    @current_user ||= UserAccount.find_by(id: payload['account_id'])
  end

  def check_permissions!
    return false unless current_user

    unless current_user.can?(action_name, controller_name)
      exception_response(I18n.t('errors.unauthorized'))
    end
  end

  private

  def exception_response(message, _status = :unprocessable_entity, resource = '')
    errors = [{ field: :base, messages: [message], resource: }]

    render Services::ComposeRenderHash.call(
      result: { model: errors },
      serializer: Api::V1::Lib::Serializers::Errors::Hash,
      status: :unauthorized
    )
  end
end
