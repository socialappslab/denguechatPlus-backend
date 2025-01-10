class AddUniqueIndexToHousesReferenceCode < ActiveRecord::Migration[7.1]
  def change
    add_index :houses, :reference_code, unique: true
  end
end
