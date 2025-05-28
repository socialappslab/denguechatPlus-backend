# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  discarded_at  :datetime
#  name          :string
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :bigint
#
# Indexes
#
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#  index_roles_on_resource                                (resource_type,resource_id)
#
class Role < ApplicationRecord
  include Discard::Model

  has_and_belongs_to_many :permissions, join_table: :roles_permissions
  has_and_belongs_to_many :user_accounts, join_table: :user_accounts_roles

  belongs_to :resource,
             :polymorphic => true,
             :optional => true


  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify
end
