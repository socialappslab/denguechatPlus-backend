class AddSelectedCaseToOption < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :selected_case, :string
  end
end
