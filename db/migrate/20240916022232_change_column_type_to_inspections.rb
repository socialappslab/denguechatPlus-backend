class ChangeColumnTypeToInspections < ActiveRecord::Migration[7.1]
  def change
    remove_column :inspections, :was_chemically_treated, :bool
    add_column :inspections, :was_chemically_treated, :string
  end
end
