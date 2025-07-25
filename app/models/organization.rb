# frozen_string_literal: true

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
class Organization < ApplicationRecord
  include Discard::Model

  has_many :teams
end
