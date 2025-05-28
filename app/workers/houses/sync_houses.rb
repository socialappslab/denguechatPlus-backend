module Houses
  class SyncHouses
    include Sidekiq::Worker

    BATCH_SIZE = 1000

    def perform
      sector_result = Gis::Neighborhood.sync(neighborhoods_data_query.keys)
      neighborhoods_data_updated = neighborhoods_data_query

      wedge_result = Gis::Wedge.sync(neighborhoods_data_updated)
      wedges_data = wedges_data_query

      house_block_result = Gis::HouseBlock.sync(house_blocks_data_query.keys, wedges_data, neighborhoods_data_updated)
      house_blocks_data = house_blocks_data_query

      mappings = {
        neighborhoods: neighborhoods_data_updated,
        wedges: wedges_data,
        house_blocks: house_blocks_data
      }
      sync_log = Gis::House.sync(BATCH_SIZE, mappings)
      sync_log.update!(sectors_created: sector_result[:create],
                       sectors_updated: sector_result[:update],
                       wedges_created: wedge_result[:create],
                       wedges_updated: wedge_result[:update],
                       house_blocks_created: house_block_result[:create],
                       house_blocks_updated: house_block_result[:update])
    end

    private

    def neighborhoods_data_query
      Neighborhood.where.not(external_id: nil).pluck(:external_id, :id).to_h
    end

    def wedges_data_query
      Wedge.where.not(external_id: nil).pluck(:external_id, :id).to_h
    end

    def house_blocks_data_query
      HouseBlock.where.not(name: nil).pluck(:name, :id).to_h
    end
  end
end
