class CreateSeedTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :seed_tasks do |t|
      t.string :task_name, null: false
      t.timestamps
    end
  end
end
