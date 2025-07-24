module Gis
  class House
    class << self
      def sync(batch_size, mappings)
        offset = 0
        total_processed = 0
        failed_records = []
        sync_log = SyncLog.create(start_date: Time.current)
        res = { created: 0, updated: 0 }

        loop do
          external_houses_batch = Gis::Connection.query(query_builder(offset, batch_size))
          break if external_houses_batch.empty?

          existing_house_teams = retrieve_existing_teams(external_houses_batch)
          houses_attributes = build_house_attributes(external_houses_batch, mappings, existing_house_teams)

          houses_attributes.each_slice(50) do |mini_batch|
            begin
              ActiveRecord::Base.transaction do
                ::House.upsert_all(
                  mini_batch.map { |attrs| attrs.except(:house_block_by_frente_a_frente, :house_block_by_block) },
                  unique_by: :reference_code,
                  returning: false
                )
              end
              total_processed += mini_batch.size
              insert_house_block_relations!(mini_batch, mappings)
            rescue StandardError
              total_processed, failed_records = process_house_one_by_one!(mini_batch, total_processed, failed_records, sync_log)
            end
          end

          offset += batch_size
        end

        sync_log.update!(
          end_date: Time.current,
          processed: total_processed,
          errors_quantity: failed_records.size
        )

        today_start = Date.today.beginning_of_day
        today_end = Date.today.end_of_day

        res[:created] = ::House.where(created_at: today_start..today_end, updated_at: today_start..today_end).count
        res[:updated] = ::House.where.not(created_at: today_start..today_end).where(updated_at: today_start..today_end).count

        sync_log.update!(houses_created: res[:created], houses_updated: res[:updated])
        sync_log
      end

      private

      def process_house_one_by_one!(mini_batch, total_processed, failed_records, sync_log)
        sync_log_id = sync_log.id
        mini_batch.each do |attrs|
          begin
            ActiveRecord::Base.transaction do
              ::House.upsert(
                attrs.except(:house_block_by_frente_a_frente, :house_block_by_block),
                unique_by: :reference_code,
                returning: false
              )
            end
            total_processed += 1
          rescue StandardError => error
            failed_records << {
              sync_log_id: sync_log_id,
              item_id: attrs[:reference_code],
              message: error.message
            }
          end
        end
        SyncLogError.create!(failed_records)
        [total_processed, failed_records]
      end

      def query_builder(offset, limit)
        <<~SQL
          SELECT DISTINCT ON (location."location_code")
            location.id AS external_id,
            location."location_code" AS reference_code,
            ST_Y(st_transform(st_centroid(geom), 4326)) AS latitude,
            ST_X(st_transform(st_centroid(geom), 4326)) AS longitude,
            location."TarikiC" AS house_block_by_frente_a_frente,
            location."block_number" AS house_block_by_block,
            location."SectorMOH24" AS sector_id,
            location."Cuna" AS wedge_id,
            'GIS' AS source,
            'orphan' AS assignment_status,
            1 AS country_id,
            4 AS state_id,
            7 AS city_id
          FROM "gis"."location" AS location
          WHERE
            location."location_code" IS NOT NULL
            AND location."deactive_date" IS NULL
            AND location."SectorMOH24" IS NOT NULL
            AND location."Cuna" IS NOT NULL
            AND location."TarikiC" IS NOT NULL
          ORDER BY location."location_code", location.id
          OFFSET #{offset}
          LIMIT #{limit}
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
          status = (ext_house[:house_block_by_frente_a_frente] || ext_house[:house_block_by_block]) ? 1 : 0

          {
            reference_code: reference_code,
            latitude: ext_house[:latitude],
            longitude: ext_house[:longitude],
            neighborhood_id: mappings[:neighborhoods][ext_house[:sector_id].to_i],
            wedge_id: mappings[:wedges][ext_house[:wedge_id].to_i],
            source: ext_house[:source],
            assignment_status: status,
            country_id: ext_house[:country_id].to_i,
            state_id: ext_house[:state_id].to_i,
            city_id: ext_house[:city_id].to_i,
            last_sync_time: Time.zone.now,
            external_id: ext_house[:external_id],
            house_block_by_frente_a_frente: ext_house[:house_block_by_frente_a_frente],
            house_block_by_block: ext_house[:house_block_by_block]
          }
        end
      end

      def insert_house_block_relations!(mini_batch, mappings)
        relations = mini_batch.flat_map do |attrs|
          house = ::House.find_by(reference_code: attrs[:reference_code])

          temp_blocks = []
          block_id1 = mappings[:house_blocks][attrs[:house_block_by_frente_a_frente]]
          temp_blocks <<  block_id1 if block_id1

          block_id2 = mappings[:house_blocks][attrs[:house_block_by_block]]
          temp_blocks << block_id2 if block_id2

          temp_blocks.uniq.map do |block_id|
            {
              house_id: house.id,
              house_block_id: block_id,
              created_at: Time.current,
              updated_at: Time.current
            }
          end
        end.compact.uniq

        ::HouseBlockHouse.insert_all(relations, unique_by: %i[house_id house_block_id]) if relations.any?
      end
    end
  end
end
