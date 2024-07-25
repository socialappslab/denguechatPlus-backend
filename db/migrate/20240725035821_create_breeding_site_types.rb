class CreateBreedingSiteTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :breeding_site_types do |t|
      t.string :name
      t.datetime :discarded_at

      t.timestamps
    end
  end
end
