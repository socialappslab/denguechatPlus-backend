class CreateHouseStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :house_statuses do |t|
      t.references :house, null: true, foreign_key: true
      t.references :house_block, null: true, foreign_key: true
      t.references :wedge, null: true, foreign_key: true
      t.references :neighborhood, null: true, foreign_key: true
      t.references :city, null: true, foreign_key: true
      t.references :country, null: true, foreign_key: true
      t.references :team, null: true, foreign_key: true
      t.integer :infected_containers, default: 0
      t.integer :non_infected_containers, default: 0
      t.integer :potential_containers, default: 0
      t.date :date

      t.timestamps
    end
    add_index :house_statuses, :team_id, if_not_exists: true
    add_index :house_statuses, :neighborhood_id, if_not_exists: true
    add_index :house_statuses, :wedge_id, if_not_exists: true
  end
end
