# frozen_string_literal: true

module Endpoint
  include SimpleEndpoint::Controller

  private

  def default_cases
    {
      created: ->(result) {
        result.success? && result.success[:type] == :created
      },
      destroyed: ->(result) {
        result.success? &&  result.success[:type] == :destroyed
      },
      unauthorized: ->(result) {
        result.failure? && %i[unauthorized unauthenticated].include?(result.failure[:type])
      },
      not_found: ->(result) {
        result.failure? &&  result.failure[:type] == :not_found
      },
      forbidden: ->(result) {
        result.failure? &&  result.failure[:type] == :forbidden
      },
      bad_request: ->(result) {
        result.failure? && result.failure[:type] == :bad_request
      },
      gone: ->(result) {
        result.failure? && result.failure[:type] == :gone
      },
      accepted: ->(result) {
        result.success? && result.success[:type].eql?(:accepted)
      },
      conflict: ->(result) {
        result.failure? && result.failure[:type] == :conflict
      },
      invalid: ->(result) {
        result.failure? && result.failure[:type] == :invalid
      },
      send_data: ->(result) {
        result.success? && result.success[:type] == :send_data
      },
      success: ->(result) {
        result.success?
      }
    }
  end

  def default_handler
    {
      created: ->(result, **opts) { render_head_or_response(result, opts, :created) },
      destroyed: ->(_result, **) { head(:no_content) },
      unauthorized: ->(result, **) { render_head_or_errors(result, :unauthorized) },
      not_found: ->(_result, **) { head(:not_found) },
      forbidden: ->(_result, **) { head(:forbidden) },
      gone: ->(_result, **) { head(:gone) },
      accepted: ->(_result, **) { head(:accepted) },
      bad_request: ->(_result, **) { head(:bad_request) },
      invalid: ->(result, **) { render_errors(result, :unprocessable_entity) },
      conflict: ->(_result, **) { head(:conflict) },
      send_data: ->(result, **) { render_send_data(result) },
      success: ->(result, **opts) { success_response(result, opts) }
    }
  end

  def endpoint_options
    { params: unsafe_params }
  end

  def unsafe_params
    params.to_unsafe_hash
  end

  def success_response(result, options)
    status = options[:serializer] ? :ok : :no_content
    render_head_or_response(result, options, status)
  end

  def render_head_or_response(result, options, status)
    options[:serializer] ? render_response(result, options, status) : head(status)
  end

  def render_head_or_errors(result, status)
    errors = result.failure[:ctx]['contract.default']
    errors ? render_errors(result, status) : head(status)
  end

  def render_errors(result, status)
    render Services::ComposeRenderHash.call(
      result: { model: error_model(result) },
      serializer: error_serializer(result),
      status:
    )
  end

  def render_response(result, options, status)
    render Services::ComposeRenderHash.call(
      result: result.success[:ctx],
      serializer: options[:serializer],
      status:
    )
  end

  def error_serializer(result)
    result.failure[:ctx]['errors'] ? Api::V1::Lib::Serializers::Errors::Hash : Api::V1::Lib::Serializers::Errors::Reform
  end

  def error_model(result)
    result.failure[:ctx]['errors'] || result.failure[:ctx]['contract.default'].errors.messages
  end

  def render_send_data(result)
    options = result[:send_data]
    send_data(options[:data], options.without(:data))
  end
end
