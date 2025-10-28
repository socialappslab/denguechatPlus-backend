class CreateVisitDuplicateCandidates < ActiveRecord::Migration[7.1]
  def change
    create_table :visit_duplicate_candidates do |t|
      t.references :visit, null: false, foreign_key: { to_table: :visits }
      t.references :duplicate_visit, null: false, foreign_key: { to_table: :visits }

      t.timestamps
    end

    add_index :visit_duplicate_candidates, %i[visit_id duplicate_visit_id], unique: true,
                                                                            name: 'idx_visit_duplicate_candidates_unique'
  end
end
