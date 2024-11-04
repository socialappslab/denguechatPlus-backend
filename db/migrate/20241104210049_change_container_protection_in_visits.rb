class ChangeContainerProtectionInVisits < ActiveRecord::Migration[7.1]
  def change
    change_column_null :inspections, :container_protection_id, true
  end
end
