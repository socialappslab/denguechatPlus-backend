class AddAditionalInfoToQuestion < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :resource_name, :string
    add_column :questions, :resource_type, :string
  end
end
