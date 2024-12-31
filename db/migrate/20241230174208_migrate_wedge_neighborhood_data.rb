class MigrateWedgeNeighborhoodData < ActiveRecord::Migration[7.1]
  def up
    Wedge.find_each do |wedge|
      if wedge.neighborhood_id.present?
        NeighborhoodWedge.create!(
          neighborhood_id: wedge.neighborhood_id,
          wedge_id: wedge.id,
          discarded_at: wedge.discarded_at
        )
      end
    end
  end

  def down
    NeighborhoodWedge.delete_all
  end
end
