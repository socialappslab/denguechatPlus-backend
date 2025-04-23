class AddDiscardedAtToInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :discarded_at, :datetime

    add_index  :inspections, :discarded_at
  end
end
