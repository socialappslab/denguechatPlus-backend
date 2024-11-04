class AddShowInCaseToOption < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :show_in_case, :string
  end
end
