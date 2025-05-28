# == Schema Information
#
# Table name: app_config_params
#
#  id           :bigint           not null, primary key
#  description  :string
#  discarded_at :datetime
#  name         :string
#  param_source :string
#  param_type   :string
#  value        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_app_config_params_on_name                   (name) UNIQUE
#  index_app_config_params_on_param_source_and_name  (param_source,name)
#
class AppConfigParam < ApplicationRecord
  include Discard::Model

end
