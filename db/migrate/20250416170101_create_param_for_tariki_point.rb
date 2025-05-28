class CreateParamForTarikiPoint < ActiveRecord::Migration[7.1]
  def change
    value = Rails.env.development? ? 1 : 0
    AppConfigParam.find_or_create_by(name: 'tariki_point_same_date',param_type: 'boolean',
                                     param_source: 'AppConfigParam',
                                     value: value,
                                     description: 'If tariki_point_same_date = true, all visits on the same day will be counted toward the total required to mark a house as tariki.')
  end
end
