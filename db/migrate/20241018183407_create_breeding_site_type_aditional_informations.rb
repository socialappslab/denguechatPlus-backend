class CreateBreedingSiteTypeAditionalInformations < ActiveRecord::Migration[7.1]
  def change
    create_table :breeding_site_type_aditional_informations do |t|
      t.string :description
      t.boolean :only_image
      t.string :title
      t.string :subtitle
      t.references :breeding_site_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
