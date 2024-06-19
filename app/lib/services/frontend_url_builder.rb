# frozen_string_literal: true

class Services::FrontendUrlBuilder
  KEY_PATH_REGEX = /\{(\D*?)\}/

  def initialize(resource_path, **params)
    @resource_path = resource_path
    @params = params.with_indifferent_access
  end

  def self.call(...)
    new(...).call
  end

  def call
    resource_url = [Rails.application.config.client_url, modified_resource_path].join
    resource_url = [resource_url, params.to_query].join('?') unless params.empty?
    resource_url
  end

  private

  attr_reader :resource_path, :params

  def modified_resource_path
    resource_path.gsub(KEY_PATH_REGEX) do |_match|
      params.delete(Regexp.last_match(1))
    end.sub(/(.+)(\/)\z/, '\1')
  end
end
