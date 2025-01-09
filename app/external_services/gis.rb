# frozen_string_literal: true

require 'pg'

class Gis
  class << self
    def connect(
      host: ENV['GIS_DB_HOST'],
      port: ENV['GIS_DB_PORT'],
      dbname: ENV['GIS_DB_NAME'],
      user: ENV['GIS_DB_USER'],
      password: ENV['GIS_DB_PASSWORD']
    )
      PG.connect(
        host: host,
        port: port,
        dbname: dbname,
        user: user,
        password: password
      )
    rescue PG::Error => e
      Rollbar.error(e, {
        message: "Error connecting to GIS database",
        context: {
          host: host,
          port: port,
          dbname: dbname,
          user: user
        }
      })
      raise ConnectionError, "Unnable to connect with GIS DB: #{e.message}"
    end

    def query(sql, params = [])
      conn = connect
      begin
        result = conn.exec_params(sql, params)
        process_result(result)
      rescue PG::Error => e
        Rollbar.error(e, {
          message: "Error executing GIS query",
          context: {
            sql: sql,
            params: params
          }
        })
        raise QueryError, "Error executing GIS query: #{e.message}"
      ensure
        conn.close if conn
      end
    end

    private

    def process_result(result)
      return [] if result.nil? || result.ntuples.zero?

      result.map { |row| symbolize_keys(row) }
    rescue StandardError => e
      Rollbar.error(e, {
        message: "Error processing GIS query result",
        context: {
          result_size: result&.ntuples,
          error_type: e.class.name
        }
      })
      raise ProcessingError, "Error processing GIS query result: #{e.message}"
    end

    def symbolize_keys(row)
      row.transform_keys(&:to_sym)
    end
  end

  class ConnectionError < StandardError; end
  class QueryError < StandardError; end
  class ProcessingError < StandardError; end
end
