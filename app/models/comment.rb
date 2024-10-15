# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id              :bigint           not null, primary key
#  content         :text
#  discarded_at    :datetime
#  likes_count     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  post_id         :bigint           not null
#  user_account_id :bigint           not null
#
# Indexes
#
#  index_comments_on_discarded_at     (discarded_at)
#  index_comments_on_post_id          (post_id)
#  index_comments_on_user_account_id  (user_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#
class Comment < ApplicationRecord
  include Discard::Model
  default_scope -> { kept }

  belongs_to :post, counter_cache: :comments_count
  has_one_attached :photo
  has_many :likes, as: :likeable, dependent: :destroy
  belongs_to :user_account

  scope :kept, -> { undiscarded.joins(:post).merge(Post.kept) }

  attr_accessor :like_by_user

  def kept?
    undiscarded? && post.kept?
  end

  after_discard do
    Post.decrement_counter(:comments_count, post.id)
  end
end
