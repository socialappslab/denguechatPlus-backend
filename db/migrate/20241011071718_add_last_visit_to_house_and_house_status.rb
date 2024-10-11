class AddLastVisitToHouseAndHouseStatus < ActiveRecord::Migration[7.1]
  def change
    add_column :house_statuses, :last_visit, :datetime
  end
end
