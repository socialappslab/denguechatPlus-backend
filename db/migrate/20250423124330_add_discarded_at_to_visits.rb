class AddDiscardedAtToVisits < ActiveRecord::Migration[7.1]
  def change
    add_column :visits, :discarded_at, :datetime

    add_index :visits, :discarded_at
  end
end
