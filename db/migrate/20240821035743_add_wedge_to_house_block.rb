class AddWedgeToHouseBlock < ActiveRecord::Migration[7.1]
  def change
    add_reference :house_blocks, :wedge, null: true, foreign_key: true

    first_wedge_id = Wedge.first&.id
    HouseBlock.update_all(wedge_id: first_wedge_id) if first_wedge_id
  end
end
