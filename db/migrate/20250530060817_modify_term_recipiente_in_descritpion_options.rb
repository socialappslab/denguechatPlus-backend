class ModifyTermRecipienteInDescritpionOptions < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      UPDATE questions
      SET description_es = REPLACE(description_es, 'recipientes/envases', 'envases')
      WHERE description_es ILIKE '%recipientes/envases%';
    SQL

    execute <<~SQL
      UPDATE questions
      SET description_es = REPLACE(description_es, 'recipiente/envase', 'envase')
      WHERE description_es ILIKE '%recipiente/envase%';
    SQL

    execute <<~SQL
      UPDATE questions
      SET description_es = REPLACE(description_es, 'recipientes', 'envases')
      WHERE description_es ILIKE '%recipientes%';
    SQL

    execute <<~SQL
      UPDATE questions
      SET description_es = REPLACE(description_es, 'recipiente', 'envase')
      WHERE description_es ILIKE '%recipiente%';
    SQL

    execute <<~SQL
      UPDATE options
      SET name_es = REPLACE(name_es, 'recipientes/envases', 'envases')
      WHERE name_es ILIKE '%recipientes/envases%';
    SQL

    execute <<~SQL
      UPDATE options
      SET name_es = REPLACE(name_es, 'recipiente/envase', 'envase')
      WHERE name_es ILIKE '%recipiente/envase%';
    SQL

    execute <<~SQL
      UPDATE options
      SET name_es = REPLACE(name_es, 'recipiente', 'envase')
      WHERE name_es ILIKE '%recipiente%';
    SQL

    execute <<~SQL
      UPDATE options
      SET name_es = REPLACE(name_es, 'recipientes', 'envases')
      WHERE name_es ILIKE '%recipientes%';
    SQL
  end
end
