class AddResumeToVisitsAndInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :visits, :status, :string
    add_column :visits, :inspection_quantity, :integer
    add_column :visits, :inspection_with_pupae, :integer
    add_column :visits, :inspection_with_eggs, :integer
    add_column :visits, :inspection_with_larvae, :integer
  end
end
