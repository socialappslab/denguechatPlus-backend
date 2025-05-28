# == Schema Information
#
# Table name: user_tokens
#
#  id                    :bigint           not null, primary key
#  data_type             :string
#  event                 :string
#  token                 :string
#  used_at               :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_account_id       :integer
#  user_code_recovery_id :string
#
class UserToken < ApplicationRecord
end
