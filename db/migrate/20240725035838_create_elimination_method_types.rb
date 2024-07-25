class CreateEliminationMethodTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :elimination_method_types do |t|
      t.string :name
      t.datetime :discarded_at

      t.timestamps
    end
  end
end
