module Gis
  class HouseBlock
    class << self

      def sync(current_house_block_ids, wedge_ids, sector_ids)
        new_house_blocks = Gis::Connection.query(query_builder(current_house_block_ids))
        if new_house_blocks.any?
          begin
            new_house_blocks.each do |house_block|

              record = ::HouseBlock.find_or_create_by(external_id: house_block[:external_id]) do |new_house_block|
                new_house_block.name = house_block[:external_id]
                new_house_block.external_id = house_block[:external_id]
                new_house_block.source = house_block[:source]
                new_house_block.wedge_id = wedge_ids[house_block[:wedge_id].to_i]
                new_house_block.neighborhood_id = sector_ids[house_block[:sector_id].to_i]
              end

              record.name = house_block[:external_id]
              record.external_id = house_block[:external_id]
              record.source = house_block[:source]
              record.wedge_id = wedge_ids[house_block[:wedge_id].to_i]
              record.neighborhood_id = sector_ids[house_block[:sector_id].to_i]
              record.last_sync_time = Time.current
              record.save! if record.changed?
            end
          rescue => e
           puts "Error with new_house_blocks: #{e}"
          end
        end
      end

      private

      def query_builder(current_house_block_ids)
        <<~SQL
          select  distinct location."Tariki" external_id,
          location."Tariki" as name,
          location."Cuna" wedge_id,
          location."SectorMOH24" sector_id,
          'GIS' as source
          from "gis"."location" as location
          where
          location."location_code" is not null
          and location."deactive_date" is null
          and location."SectorMOH24" is not null
          and location."Cuna" is not null
        SQL
      end
    end
  end
end
