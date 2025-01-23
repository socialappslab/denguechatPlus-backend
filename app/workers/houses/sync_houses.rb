module Houses
  class SyncHouses
    include Sidekiq::Worker

    BATCH_SIZE = 1000

    def perform
      mappings = {
        neighborhoods: Neighborhood.where.not(external_id: nil).pluck(:external_id, :id).to_h,
        wedges: Wedge.where.not(external_id: nil).pluck(:external_id, :id).to_h,
        house_blocks: HouseBlock.where.not(external_id: nil).pluck(:external_id, :id).to_h
      }

      Gis::Neighborhood.sync(mappings[:neighborhoods].keys)
      Gis::Wedge.sync(mappings[:neighborhoods])
      Gis::HouseBlock.sync(mappings[:house_blocks].keys, mappings[:wedges])
      Gis::House.sync(BATCH_SIZE, mappings)
    end
  end
end
