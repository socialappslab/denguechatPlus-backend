class ResetLikesCounter < ActiveRecord::Migration[7.1]
  def up
    Post.find_each { |post| Post.reset_counters(post.id, :likes) }
    Comment.find_each { |comment| Comment.reset_counters(comment.id, :likes) }
  end
end
