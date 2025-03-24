module Gis
  class Wedge
    class << self
      def sync(neighborhood_ids)
        new_changes = Gis::Connection.query(query_builder_update)
        new_data = Gis::Connection.query(query_builder)
        {update: update_wedges(new_changes, neighborhood_ids), create: new_wedges(new_data, neighborhood_ids)}
      end

      private

      def new_wedges(sql_result, neighborhood_ids)
        qty = 0
        if sql_result.any?
          begin
            sql_result.each do |wedge|
              ::Wedge.find_or_create_by(external_id: wedge[:external_id]) do |new_wedge|
                new_wedge.name = wedge[:name]
                new_wedge.external_id = wedge[:external_id]
                new_wedge.source = wedge[:source]
                new_wedge.neighborhood_ids = wedge[:neighborhood_ids].split(',').map{|ext_id| neighborhood_ids[ext_id.to_i]}
              end
              qty += 1
            end
          rescue => e
            puts "Error with new_wedges: #{e}"
          end
        end
        qty
      end

      def update_wedges(sql_result, neighborhood_ids)
        qty = 0
        if sql_result.any?
          begin
            sql_result.each do |wedge|
              wedge_record = ::Wedge.find_or_initialize_by(external_id: wedge[:external_id])
              wedge_record.update(
                name: wedge[:name],
                source: wedge[:source],
                neighborhood_ids: wedge[:neighborhood_ids].split(',').map { |ext_id| neighborhood_ids[ext_id.to_i] }
              )
              qty += 1
            end
          rescue => e
            puts "Error with new_wedges: #{e}"
          end
        end
        qty
      end
      def query_builder
        current_wedges = ::Wedge.pluck(:external_id).join(',')
        <<~SQL
          SELECT
              location."Cuna" as external_id,
              concat('Cuña ', location."Cuna") as name,
              STRING_AGG(DISTINCT CAST(location."SectorMOH24" AS TEXT), ', ') as neighborhood_ids,
              'GIS' as source
          FROM "gis"."location" as location
          WHERE
              location."location_code" is not null
              AND location."deactive_date" is null
              AND location."SectorMOH24" is not null
              AND location."Cuna" not in (#{current_wedges})
              AND location."block_number" is not null
          GROUP BY location."Cuna"
        SQL
      end

      def query_builder_update
        current_wedges = ::Wedge.pluck(:external_id).join(',')
        <<~SQL
          SELECT
              location."Cuna" as external_id,
              concat('Cuña ', location."Cuna") as name,
              STRING_AGG(DISTINCT CAST(location."SectorMOH24" AS TEXT), ', ') as neighborhood_ids,
              'GIS' as source
          FROM "gis"."location" as location
          WHERE
              location."location_code" is not null
              AND location."deactive_date" is null
              AND location."SectorMOH24" is not null
              AND location."Cuna" in (#{current_wedges})
              AND location."block_number" is not null
          GROUP BY location."Cuna"
        SQL
      end
    end
  end
end
