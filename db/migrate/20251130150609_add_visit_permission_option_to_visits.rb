# frozen_string_literal: true

class AddVisitPermissionOptionToVisits < ActiveRecord::Migration[7.1]
  def change
    add_reference :visits, :visit_permission_option, foreign_key: { to_table: :options }, null: true
    add_column :visits, :visit_permission_other, :string
  end
end
