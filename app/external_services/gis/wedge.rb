module Gis
  class Wedge
    class << self
      def sync(neighborhood_ids)
        new_wedges = Gis::Connection.query(query_builder)
        if new_wedges.any?
          begin
            new_wedges.each do |wedge|
              ::Wedge.find_or_create_by(external_id: wedge[:external_id]) do |new_wedge|
                new_wedge.name = wedge[:external_id]
                new_wedge.external_id = wedge[:external_id]
                new_wedge.source = wedge[:source]
                new_wedge.neighborhood_ids = wedge[:neighborhood_ids].split(',').map{|ext_id| neighborhood_ids[ext_id.to_i]}
              end
            end
          rescue => e
            log.puts "Error with new_wedges: #{e}"
          end
        end
      end

      private
      def query_builder
        current_wedges = NeighborhoodWedge.distinct.pluck(Arel.sql("concat('''', wedge_id || '-' || neighborhood_id, '''')")).join(',')
        <<~SQL
          SELECT
              location."Cuna" as external_id,
              location."Cuna" as name,
              STRING_AGG(DISTINCT CAST(location."SectorMOH24" AS TEXT), ', ') as neighborhood_ids,
              'GIS' as source
          FROM "gis"."location" as location
          WHERE
              location."location_code" is not null
              AND location."deactive_date" is null
              AND location."SectorMOH24" is not null
              AND location."Cuna" || '-' || location."SectorMOH24" not in (#{current_wedges})
              AND location."block_number" is not null
          GROUP BY location."Cuna"
        SQL
      end
    end
  end
end
