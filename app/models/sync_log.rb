# == Schema Information
#
# Table name: sync_logs
#
#  id              :bigint           not null, primary key
#  end_date        :datetime
#  errors_quantity :integer
#  processed       :integer
#  start_date      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class SyncLog < ApplicationRecord
  has_many :sync_log_errors, dependent: :destroy
  accepts_nested_attributes_for :sync_log_errors, allow_destroy: true
end
