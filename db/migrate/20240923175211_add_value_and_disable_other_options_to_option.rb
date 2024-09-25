class AddValueAndDisableOtherOptionsToOption < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :value, :string
    add_column :options, :disable_other_options, :boolean, default: false
  end
end
