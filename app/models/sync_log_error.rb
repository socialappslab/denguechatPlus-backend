# == Schema Information
#
# Table name: sync_log_errors
#
#  id          :bigint           not null, primary key
#  message     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  item_id     :string
#  sync_log_id :bigint           not null
#
# Indexes
#
#  index_sync_log_errors_on_sync_log_id  (sync_log_id)
#
# Foreign Keys
#
#  fk_rails_...  (sync_log_id => sync_logs.id)
#
class SyncLogError < ApplicationRecord
  belongs_to :sync_log
end
