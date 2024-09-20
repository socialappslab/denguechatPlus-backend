class ChangeDeletedAtToDiscardedAtToComment < ActiveRecord::Migration[7.1]
  def change
    remove_column :comments, :deleted_at, :datetime
    remove_column :posts, :deleted_at, :datetime
    add_column :comments, :discarded_at, :datetime
    add_column :posts, :discarded_at, :datetime

    add_index :posts, :discarded_at
    add_index :comments, :discarded_at
  end
end
