module Gis
  class Neighborhood
    class << self
      def sync(_current_neighborhood_keys)
        res = { update: 0, create: 0 }
        external_data = Gis::Connection.query(query_builder)
        external_data.each do |obj|
          sector_instance = ::Neighborhood.find_or_initialize_by(obj)
          res[:update] += 1 if sector_instance.persisted?
          res[:create] += 1 unless sector_instance.persisted?
          sector_instance.save!
        end
        res
      end

      private

      def query_builder
        <<~SQL.squish
          select distinct location."SectorMOH24" external_id,
          'Sector ' || location."SectorMOH24" as name,
          1 as country_id,
          4 as state_id,
          7 as city_id
          from "gis"."location" as location
          where
          location."location_code" is not null
          and location."deactive_date" is null
          and location."SectorMOH24" is not null
          and location."Cuna" is not null
          and location."block_number" is not null
        SQL
      end
    end
  end
end
