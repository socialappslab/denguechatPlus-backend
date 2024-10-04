class AddOtherEliminationMethodToInspection < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :other_elimination_method, :string
  end
end
