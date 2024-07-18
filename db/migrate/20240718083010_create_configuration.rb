class CreateConfiguration < ActiveRecord::Migration[7.1]
  def change
    create_table :configurations do |t|
      t.string :field_name, null: false
      t.string :value
      t.timestamps
    end
  end
end
