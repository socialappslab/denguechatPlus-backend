module Gis
  class Neighborhood
    class << self
      def sync(current_neighborhood_keys)
        res = {update: 2, create: 0}
        query = query_builder(current_neighborhood_keys)
        new_neighborhoods = Gis::Connection.query(query)
        res[:create] = new_neighborhoods.count
        ::Neighborhood.create!(new_neighborhoods) if new_neighborhoods.any?
        res
      end

      private

      def query_builder(current_neighborhood_keys)
        <<~SQL
          select  distinct location."SectorMOH24" external_id,
          'Sector ' || location."SectorMOH24" as name,
          1 as country_id,
          4 as state_id,
          7 as city_id
          from "gis"."location" as location
          where
          location."location_code" is not null
          and location."deactive_date" is null
          and location."SectorMOH24" not in (#{current_neighborhood_keys.join(',')})
          and location."Cuna" is not null
          and location."block_number" is not null
        SQL
      end
    end
  end
end
