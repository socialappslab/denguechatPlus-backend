# frozen_string_literal: true

class RemoveUnusedColumnsFromVisits < ActiveRecord::Migration[7.1]
  def change
    remove_column :visits, :questions, :jsonb
    remove_column :visits, :visit_status, :integer
    remove_column :visits, :inspection_quantity, :integer
    remove_column :visits, :inspection_with_eggs, :integer
    remove_column :visits, :inspection_with_larvae, :integer
    remove_column :visits, :inspection_with_pupae, :integer
  end
end
