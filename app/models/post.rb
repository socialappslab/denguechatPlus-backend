# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id              :bigint           not null, primary key
#  comments_count  :integer          default(0)
#  content         :text
#  discarded_at    :datetime
#  likes_count     :integer
#  location        :string
#  visibility      :string           default("public")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  city_id         :bigint           not null
#  country_id      :bigint           not null
#  neighborhood_id :bigint           not null
#  team_id         :bigint           not null
#  user_account_id :bigint           not null
#
# Indexes
#
#  index_posts_on_city_id          (city_id)
#  index_posts_on_country_id       (country_id)
#  index_posts_on_discarded_at     (discarded_at)
#  index_posts_on_neighborhood_id  (neighborhood_id)
#  index_posts_on_team_id          (team_id)
#  index_posts_on_user_account_id  (user_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id)
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (neighborhood_id => neighborhoods.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#
class Post < ApplicationRecord
  include Discard::Model
  default_scope -> { kept }

  has_many_attached :photos
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, dependent: :destroy, counter_cache: :comments_count
  belongs_to :city
  belongs_to :user_account
  belongs_to :team
  belongs_to :neighborhood
  belongs_to :country
  attr_accessor :like_by_user

  def liked_by_user?(user)
    likes.where(user_account_id: user.id).exists?
  end
end
