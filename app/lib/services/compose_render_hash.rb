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
      response_hash
    end

    private

    def serialized_json
      serializable_hash = @serializer.new(@model, **options).serializable_hash
      ActiveSupport::JSON.encode(serializable_hash)
    end

    def response_hash
      @response_hash ||= {
        json: serialized_json,
        status: @status
      }
    end

    def options
      {
        meta: @meta,
        links:,
        include:,
        params: @expose
      }
    end

    def links
      @pagy ? pagination_links : nil
    end

    def pagination_links
      {
        self: @pagy.page,
        last: @pagy.pages
      }
    end

    def include
      @include ? includes_array : nil
    end

    def includes_array
      return @include.underscore.split(',') if @include.is_a?(String)

      @include.map(&:underscore)
    end

    def debug_response
      Rails.logger.debug(
        ActiveSupport::LogSubscriber.new.send(
          :color,
          "RESPONSE: \n#{JSON.parse response_hash[:jsonapi]} \nwith status: #{response_hash[:status]}",
          :yellow
        )
      )
    end
  end
end
