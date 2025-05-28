module Services
  class AlbaJson

    def self.call(**opts)
      new(**opts).response_hash
    end

    def initialize(**opts)
      @opts = opts
    end

    def response_hash
      @response_hash ||= {
        json: serialized_json,
        status: @opts[:status]
      }
    end



    private

    def serialized_json
      @opts[:serializer].new(@opts[:model]).serialize
    end

    def options
      {
        meta: @opts[:meta],
        links:,
        include:,
        params: @opts[:expose]
      }
    end

    def links
      @opts[:pagy] ? pagination_links : nil
    end

    def pagination_links
      {
        self: @opts[:pagy].page,
        last: @opts[:pagy].pages
      }
    end

    def include
      @opts[:include] ? includes_array : nil
    end

    def includes_array
      return @opts[:include].underscore.split(',') if @opts[:include].is_a?(String)

      @opts[:include].map(&:underscore)
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
