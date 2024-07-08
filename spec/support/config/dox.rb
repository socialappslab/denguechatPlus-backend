# frozen_string_literal: true

require 'dox'

Dox::DSL::Action.class_eval do
  def jsonapi_include(params)
    { include: { type: :string, required: false, value: params } }
  end

  def json_filter(optional = true, **params)
    {
      filter: {
        type: :object,
        required: required_marker(optional),
        value: params
      }
    }
  end

  def jsonapi_sort(fields)
    { sort: { type: :string, required: false, value: fields } }
  end

  def jsonapi_pagination(optional: true)
    {
      page: {
        type: :object,
        required: required_marker(optional),
        value: { number: 1, size: 2 }
      }
    }
  end

  def cursor_pagination(optional: true)
    {
      page: {
        type: :object,
        required: required_marker(optional),
        value: { after: 1, before: 2 }
      }
    }
  end

  def jsonapi_cursor_pagination(optional: true, **params)
    {
      page: {
        type: :object,
        required: required_marker(optional),
        value: params
      }
    }
  end

  private

  def required_marker(optional)
    optional ? false : :required
  end
end

Dir[Rails.root.join('spec/api_doc/**/*.rb')].each { |f| require f }

Dox.configure do |config|
  config.api_version = '1.0'
  config.title = 'DengueChatPlus API Documentation'
  config.header_description = 'header.md'
  config.descriptions_location = Rails.root.join('spec/api_doc/v1/descriptions')
  config.headers_whitelist = %w[Accept Authorization X-Refresh-Token]
end

RSpec.configure do |config|
  config.after(:each, :dox) do |example|
    example.metadata[:request] = request
    example.metadata[:response] = response
  end
end

RSpec.configure do |config|
  config.after(:each, :dox) do |example|
    response.body.gsub!("\r\n", "\n")
    example.metadata[:response] = response
  end
end
