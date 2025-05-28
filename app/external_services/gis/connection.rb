# frozen_string_literal: true

require 'pg'

module Gis
  class Connection
    class << self
      def create(
        host: ENV.fetch('GIS_DB_HOST', nil),
        port: ENV.fetch('GIS_DB_PORT', nil),
        dbname: ENV.fetch('GIS_DB_NAME', nil),
        user: ENV.fetch('GIS_DB_USER', nil),
        password: ENV.fetch('GIS_DB_PASSWORD', nil)
      )
        PG.connect(
          host: host,
          port: port,
          dbname: dbname,
          user: user,
          password: password
        )
      rescue PG::Error => error
        Sentry.with_scope do |scope|
          scope.set_extra('message', 'Error connecting to GIS database')
          scope.set_context('database', {
                              host: host,
                              port: port,
                              dbname: dbname,
                              user: user
                            })
          Sentry.capture_exception(error)
        end
        raise ConnectionError, "Unnable to connect with GIS DB: #{error.message}"
      end

      def query(sql, params = [])
        conn = create
        begin
          result = conn.exec_params(sql, params)
          process_result(result)
        rescue PG::Error => error
          Sentry.with_scope do |scope|
            scope.set_extra('message', 'Error executing GIS query')
            scope.set_context('query', {
                                sql: sql,
                                params: params
                              })
            Sentry.capture_exception(error)
          end
          raise QueryError, "Error executing GIS query: #{error.message}"
        ensure
          conn.close if conn
        end
      end

      private

      def process_result(result)
        return [] if result.nil? || result.ntuples.zero?

        result.map { |row| symbolize_keys(row) }
      rescue StandardError => error
        Sentry.with_scope do |scope|
          scope.set_extra('message', 'Error processing GIS query result')
          scope.set_context('result', {
                              size: result&.ntuples,
                              error_type: error.class.name
                            })
          Sentry.capture_exception(error)
        end
        raise ProcessingError, "Error processing GIS query result: #{error.message}"
      end

      def symbolize_keys(row)
        row.transform_keys(&:to_sym)
      end
    end

    class ConnectionError < StandardError; end
    class QueryError < StandardError; end
    class ProcessingError < StandardError; end
  end
end
