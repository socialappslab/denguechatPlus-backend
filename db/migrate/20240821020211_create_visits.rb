class CreateVisits < ActiveRecord::Migration[7.1]
  def change
    create_table :visits do |t|
      t.references :house, null: false, foreign_key: true
      t.datetime :visited_at
      t.references :user_account, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.boolean :visit_permission, default: false
      t.string :notes
      t.string :host
      t.jsonb :questions
      t.references :questionnaire, null: false, foreign_key: true
      t.jsonb :answers
      t.integer :visit_status

      t.timestamps
    end
  end
end
