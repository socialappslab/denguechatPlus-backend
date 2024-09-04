# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id              :bigint           not null, primary key
#  content         :text
#  deleted_at      :datetime
#  likes_count     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  post_id         :bigint           not null
#  user_account_id :bigint           not null
#
# Indexes
#
#  index_comments_on_post_id          (post_id)
#  index_comments_on_user_account_id  (user_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#
class Comment < ApplicationRecord
  belongs_to :post
  has_one_attached :photo
  has_many :likes, as: :likeable, dependent: :destroy

  validates :content, presence: true
end
