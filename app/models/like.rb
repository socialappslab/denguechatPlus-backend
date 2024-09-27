# frozen_string_literal: true

# == Schema Information
#
# Table name: likes
#
#  id              :bigint           not null, primary key
#  likeable_type   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  likeable_id     :bigint           not null
#  user_account_id :bigint           not null
#
# Indexes
#
#  index_likes_on_likeable         (likeable_type,likeable_id)
#  index_likes_on_user_account_id  (user_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_account_id => user_accounts.id)
#
class Like < ApplicationRecord
  belongs_to :likeable, polymorphic: true, counter_cache: :likes_count
  belongs_to :user_account
end
