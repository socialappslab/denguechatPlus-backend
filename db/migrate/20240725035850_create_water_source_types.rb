class CreateWaterSourceTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :water_source_types do |t|
      t.string :name
      t.datetime :discarded_at

      t.timestamps
    end
  end
end
