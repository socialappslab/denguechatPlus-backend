# frozen_string_literal: true

module Services
  class ComposeRenderHash
    def self.call(...)
      new(...).call
    end

    def initialize(result:, serializer:, status:)
      @model = result[:model] || result[:data]
      @serializer = serializer
      @include = result.to_hash.dig(:params, :include) || result[:include]
      @meta = result[:meta]
      @pagy = result[:pagy]
      @expose = result[:expose]
      @status = status
    end

    def call
      debug_response if %w[staging sandbox release].include? Rails.env
      params = {model: @model, serializer: @serializer,
                include: @include,
                pagy: @pagy,
                expose: @expose,
                status: @status}

      return Services::FastJson.call(**params) if @serializer.superclass == ApplicationSerializer

      Services::AlbaJson.call(**params) if @serializer.superclass

    end

    private


  end
end
