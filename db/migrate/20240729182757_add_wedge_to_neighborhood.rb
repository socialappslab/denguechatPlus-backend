class AddWedgeToNeighborhood < ActiveRecord::Migration[7.1]
  def change
    add_reference :neighborhoods, :wedge, null: true, foreign_key: true
  end
end
