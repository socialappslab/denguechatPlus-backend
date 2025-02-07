module Gis
  class House
    class << self
      def sync(batch_size, mappings)
        offset = 0
        total_processed = 0
        failed_records = []
        sync_log = SyncLog.create(start_date: Time.current)

        loop do
          external_houses_batch = Gis::Connection.query(query_builder(offset, batch_size))
          break if external_houses_batch.empty?

          existing_house_teams = retrieve_existing_teams(external_houses_batch)
          houses_attributes = build_house_attributes(external_houses_batch, mappings, existing_house_teams)

          houses_attributes.each_slice(50) do |mini_batch|
            begin
              ActiveRecord::Base.transaction do
                ::House.upsert_all(
                  mini_batch,
                  unique_by: :reference_code,
                  returning: false
                )
              end
              total_processed += mini_batch.size
            rescue => e
              total_processed, failed_records = process_house_one_by_one!(mini_batch, total_processed, failed_records, sync_log)
            end
          end

          offset += batch_size
        end
        sync_log.update!(end_date: Time.current,
                         processed: total_processed, errors_quantity: failed_records.size)
      end

      private

      def process_house_one_by_one!(mini_batch, total_processed, failed_records, sync_log)
        sync_log_id = sync_log.id
        mini_batch.each do |attrs|
          begin
            ActiveRecord::Base.transaction do
              ::House.upsert(
                attrs,
                unique_by: :reference_code,
                returning: false
              )
            end
            total_processed += 1
          rescue => individual_error
            failed_records << {
              sync_log_id:,
              item_id: attrs[:reference_code],
              message: individual_error.message
            }
          end
        end
        SyncLogError.create!(failed_records)
        [total_processed, failed_records]
      end

      def query_builder(offset, limit)
        <<~SQL
          select DISTINCT ON (location."location_code")
          location.id external_id,
          location."location_code" reference_code,
          ST_Y(st_transform(st_centroid(geom), 4326)) as latitude,
          ST_X(st_transform(st_centroid(geom), 4326)) as longitude,
          location."Tariki" house_block_id,
          location."SectorMOH24" sector_id,
          location."Cuna" wedge_id,
          'GIS' as source,
          'orphan' as assignment_status,
          1 as country_id,
          4 as state_id,
          7 as city_id
          from "gis"."location" as location
          where
          location."location_code" is not null
          and location."deactive_date" is null
          and location."SectorMOH24" is not null
          and location."Cuna" is not null
          and location."Tariki" is not null
          ORDER BY location."location_code", location.id
          offset #{offset}
          limit #{limit}
        SQL
      end

      def retrieve_existing_teams(external_houses_batch)
        ::House.includes(:team)
               .where(reference_code: external_houses_batch.pluck(:reference_code))
               .pluck(:reference_code, 'teams.id')
               .to_h
      end

      def build_house_attributes(external_houses_batch, mappings, existing_house_teams)
        external_houses_batch.map do |ext_house|
          reference_code = ext_house[:reference_code]

          has_team = existing_house_teams.key?(reference_code) && existing_house_teams[reference_code].present?
          status = ext_house[:house_block_id] ? 1 : 0

          {
            reference_code:,
            latitude: ext_house[:latitude],
            longitude: ext_house[:longitude],
            house_block_id: mappings[:house_blocks][ext_house[:house_block_id].to_i],
            neighborhood_id: mappings[:neighborhoods][ext_house[:sector_id].to_i],
            wedge_id: mappings[:wedges][ext_house[:wedge_id].to_i],
            source: ext_house[:source],
            assignment_status: status,
            country_id: ext_house[:country_id].to_i,
            state_id: ext_house[:state_id].to_i,
            city_id: ext_house[:city_id].to_i,
            last_sync_time: Time.zone.now,
            external_id: ext_house[:external_id],
          }
        end
      end
    end
  end
end
