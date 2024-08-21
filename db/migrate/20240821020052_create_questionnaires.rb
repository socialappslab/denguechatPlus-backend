class CreateQuestionnaires < ActiveRecord::Migration[7.1]
  def change
    create_table :questionnaires do |t|
      t.string :name
      t.boolean :current_form
      t.datetime :discarded_at
      t.integer :initial_question
      t.integer :final_question

      t.timestamps
    end
  end
end
