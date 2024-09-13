class AddAditionalInfoToOption < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :resource_id, :integer
  end
end
