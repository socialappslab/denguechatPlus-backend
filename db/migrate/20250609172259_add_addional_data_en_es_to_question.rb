class AddAddionalDataEnEsToQuestion < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :additional_data_en, :jsonb, default: {}, null: true
    add_column :questions, :additional_data_pt, :jsonb, default: {}, null: true
    rename_column :questions, :additional_data, :additional_data_es
  end
end
