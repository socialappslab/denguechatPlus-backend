class AddHouseToPoint < ActiveRecord::Migration[7.1]
  def change
    add_column :points, :house_id, :integer
    add_column :points, :visit_id, :integer
  end
end
