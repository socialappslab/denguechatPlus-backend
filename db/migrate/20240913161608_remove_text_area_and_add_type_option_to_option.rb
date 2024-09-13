class RemoveTextAreaAndAddTypeOptionToOption < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :type_option, :string
    remove_column :options, :text_area, :string
  end
end
