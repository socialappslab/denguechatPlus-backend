class ChangeEliminationMethodTypeInVisits < ActiveRecord::Migration[7.1]
  def change
    change_column_null :inspections, :elimination_method_type_id, true
  end
end
