class CreateCountries < ActiveRecord::Migration[7.1]
  def change
    create_table :countries do |t|
      t.string :name
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :countries, :discarded_at
    add_index :countries, :name
  end
end
