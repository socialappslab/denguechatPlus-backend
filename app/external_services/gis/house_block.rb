module Gis
  class HouseBlock
    class << self
      def sync(current_house_block_ids, wedge_ids, sector_ids)
        res = { update: 0, create: 0 }
        new_house_blocks = Gis::Connection.query(query_builder(current_house_block_ids))
        if new_house_blocks.any?
          begin
            new_house_blocks.each do |house_block|
              wedge_ids[house_block[:wedge_id].to_i]
              record = ::HouseBlock.find_or_initialize_by(name: house_block[:name])

              record.name = house_block[:name]
              record.source = house_block[:source]
              record.neighborhood_id = sector_ids[house_block[:sector_id].to_i]
              record.last_sync_time = Time.current

              if record.new_record?
                res[:create] += 1
                record.wedge_ids = [wedge_ids[house_block[:wedge_id].to_i]]
              else
                res[:update] += 1
                current_wedge_ids = record.wedge_ids
                record.wedge_ids = current_wedge_ids | [wedge_ids[house_block[:wedge_id].to_i]]
              end

              record.save!
            end
          rescue StandardError => error
            puts "Error with new_house_blocks: #{error}"
          end
        end
        res
      end

      private

      def query_builder(_current_house_block_ids)
        <<~SQL
              SELECT DISTINCT#{' '}
              location."TarikiC" as external_id,
              location."TarikiC" as name,
              location."Cuna" as wedge_id,
              location."SectorMOH24" as sector_id,
              'GIS' as source
          FROM "gis"."location" as location
          WHERE
              location."location_code" is not null
              AND location."deactive_date" is null
              AND location."SectorMOH24" is not null#{' '}
              AND location."Cuna" is not null
          GROUP BY location."TarikiC", location."Cuna", location."SectorMOH24"
        SQL
      end
    end
  end
end
