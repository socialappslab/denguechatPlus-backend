module Gis
  class HouseBlock
    class << self

      def sync(current_house_block_ids, wedge_ids)
        new_house_blocks = Gis::Connection.query(query_builder(current_house_block_ids))
        if new_house_blocks.any?
          begin
            new_house_blocks.each do |house_block|
              ::HouseBlock.find_or_create_by(external_id: house_block[:external_id]) do |new_house_block|
                new_house_block.name = house_block[:external_id]
                new_house_block.external_id = house_block[:external_id]
                new_house_block.source = house_block[:source]
                new_house_block.wedge_id = wedge_ids[house_block[:wedge_id].to_i]
              end
            end
          rescue => e
            log.puts "Error with new_house_blocks: #{e}"
          end
        end
      end

      private

      def query_builder(current_house_block_ids)
        <<~SQL
          select  distinct location."block_number" external_id,
          location."block_number" as name,
          location."Cuna" wedge_id,
          'GIS' as source
          from "gis"."location" as location
          where
          location."location_code" is not null
          and location."deactive_date" is null
          and location."SectorMOH24" is not null
          and location."Cuna" is not null
          and location."block_number" not in (#{current_house_block_ids.join(',')})
        SQL
      end
    end
  end
end
