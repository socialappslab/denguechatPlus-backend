module Services
  class ActiveModelSerializer

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
       serialize_collection(@opts[:serializer], @opts[:model]).to_json

      #  serialize_resource(@opts[:serializer], @opts[:model])
    end

    def options
      {
        meta: @opts[:meta],
        links:,
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

    def serialize_collection(serializer, collection)
      res = {}
      res[:data] = ActiveModelSerializers::SerializableResource.new(collection, each_serializer: serializer, **options).as_json
      res[:meta] = options if options && options[:meta]
      res
    end

    def serialize_resource(serializer, resource, **options)
      serializer.new(resource)
    end

  end
end
