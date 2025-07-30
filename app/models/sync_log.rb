# == Schema Information
#
# Table name: sync_logs
#
#  id                            :bigint           not null, primary key
#  end_date                      :datetime
#  errors_quantity               :integer
#  house_blocks_created          :integer
#  house_blocks_created_by_block :integer          default(0)
#  house_blocks_updated          :integer
#  house_blocks_updated_by_block :integer          default(0)
#  houses_created                :integer
#  houses_updated                :integer
#  processed                     :integer
#  sectors_created               :integer
#  sectors_updated               :integer
#  start_date                    :datetime
#  wedges_created                :integer
#  wedges_updated                :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class SyncLog < ApplicationRecord
  has_many :sync_log_errors, dependent: :destroy
  accepts_nested_attributes_for :sync_log_errors, allow_destroy: true
end
