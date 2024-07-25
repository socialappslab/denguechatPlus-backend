class CreatePlaces < ActiveRecord::Migration[7.1]
  def change
    create_table :places do |t|
      t.string :name
      t.string :category
      t.datetime :discarded_at

      t.timestamps
    end
  end
end
