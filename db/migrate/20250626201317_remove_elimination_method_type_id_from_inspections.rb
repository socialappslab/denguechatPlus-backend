class RemoveEliminationMethodTypeIdFromInspections < ActiveRecord::Migration[7.1]
  def change
    remove_reference :inspections, :elimination_method_type, foreign_key: true
  end
end
