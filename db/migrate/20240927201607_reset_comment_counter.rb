class ResetCommentCounter < ActiveRecord::Migration[7.1]
  def up
    Post.find_each { |post| Post.reset_counters(post.id, :comments) }
  end
end
