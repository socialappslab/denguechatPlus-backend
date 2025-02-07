module Houses
  class SyncHouses
    include Sidekiq::Worker

    BATCH_SIZE = 1000

    def perform

      Gis::Neighborhood.sync(neighborhoods_data_query.keys)
      neighborhoods_data_updated = neighborhoods_data_query

      Gis::Wedge.sync(neighborhoods_data_updated)
      wedges_data = wedges_data_query

      Gis::HouseBlock.sync(house_blocks_data_query.keys, wedges_data, neighborhoods_data_updated)
      house_blocks_data = house_blocks_data_query

      mappings = {
        neighborhoods: neighborhoods_data_updated,
        wedges: wedges_data,
        house_blocks: house_blocks_data
      }
      Gis::House.sync(BATCH_SIZE, mappings)
    end

    private
    def neighborhoods_data_query
      Neighborhood.where.not(external_id: nil).pluck(:external_id, :id).to_h
    end

    def wedges_data_query
      Wedge.where.not(external_id: nil).pluck(:external_id, :id).to_h
    end

    def house_blocks_data_query
      HouseBlock.where.not(external_id: nil).pluck(:external_id, :id).to_h
    end
  end
end
