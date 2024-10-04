class FillVisibilityForExistingPost < ActiveRecord::Migration[7.1]
  def up
    Post.all.each do  |post|
      post.visibility = 'public' if post.visibility.nil?
      post.save!
    end
  end
end
