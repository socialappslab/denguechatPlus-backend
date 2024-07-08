# == Schema Information
#
# Table name: seed_tasks
#
#  id         :bigint           not null, primary key
#  task_name  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SeedTask < ApplicationRecord
end
