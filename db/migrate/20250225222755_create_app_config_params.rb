class CreateAppConfigParams < ActiveRecord::Migration[7.1]
  def change
    create_table :app_config_params do |t|
      t.string :name
      t.string :description
      t.string :param_source
      t.string :param_type
      t.string :value

      t.timestamps
    end

    add_index :app_config_params, :name, unique: true
    add_index :app_config_params, %i[param_source name]

    reversible do |dir|
      dir.up do
        AppConfigParam.create!([
                                 {
                                   name: 'green_house_points_user_account',
                                   description: 'Points assigned to brigadist when a house is green continuously for a specific number of times',
                                   param_source: 'TarikiPoint',
                                   param_type: 'integer',
                                   value: '1'
                                 },
                                 {
                                   name: 'green_house_points_team',
                                   description: 'Points assigned to team when a house is green continuously for a specific number of times',
                                   param_source: 'TarikiPoint',
                                   param_type: 'integer',
                                   value: '2'
                                 },
                                 {
                                   name: 'consecutive_green_statuses_for_tariki_house',
                                   description: "Number of consecutive visits with 'Green House' status required for a house to be promoted to 'Tariki House' status", param_source: 'TarikiPoint',
                                   param_type: 'integer',
                                   value: '1'
                                 }
                               ])
      end
    end
  end
end
