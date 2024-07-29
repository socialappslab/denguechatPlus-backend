class AddWedgeToBrigade < ActiveRecord::Migration[7.1]
  def change
    add_reference :teams, :wedge, null: true, foreign_key: true
  end
end
