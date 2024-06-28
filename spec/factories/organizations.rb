# == Schema Information
#
# Table name: organizations
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_organizations_on_discarded_at  (discarded_at)
#  index_organizations_on_name          (name) UNIQUE
#
FactoryBot.define do
  factory :organization do
    name { "MyString" }
    discarded_at { "2024-06-28 03:13:06" }
  end
end
