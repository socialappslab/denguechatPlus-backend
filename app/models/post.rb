# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id              :bigint           not null, primary key
#  content         :text
#  deleted_at      :datetime
#  likes_count     :integer
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
  has_many_attached :photos
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :city
  belongs_to :user_account
  belongs_to :team
  belongs_to :neighborhood
  belongs_to :country
end
