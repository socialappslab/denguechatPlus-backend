class RemoveNeighborhoodFromWedges < ActiveRecord::Migration[7.1]
  def change
    remove_reference :wedges, :neighborhood, index: true, foreign_key: true
  end
end
