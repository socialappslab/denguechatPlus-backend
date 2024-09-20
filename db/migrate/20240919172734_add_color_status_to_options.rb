class AddColorStatusToOptions < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :status_color, :string
  end
end
