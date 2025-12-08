class RemoveVisitPermissionFromVisits < ActiveRecord::Migration[7.1]
  def change
    remove_column :visits, :visit_permission, :boolean
  end
end
