class ReplaceRecipienteEnvaseInQuestions < ActiveRecord::Migration[7.1]
  def up
    question = Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')
    question.next = 3
    question.save!

    execute <<~SQL
      UPDATE questions
      SET question_text_es = REPLACE(question_text_es, 'recipientes/envases', 'envases')
      WHERE question_text_es ILIKE '%recipientes/envases%';
    SQL

    execute <<~SQL
      UPDATE questions
      SET question_text_es = REPLACE(question_text_es, 'recipiente/envase', 'envase')
      WHERE question_text_es ILIKE '%recipiente/envase%';
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
  end

  def down
    execute <<~SQL
      UPDATE questions
      SET question_text_es = REPLACE(question_text_es, 'envases', 'recipientes/envases')
      WHERE question_text_es ILIKE '%envases%';
    SQL

    execute <<~SQL
      UPDATE questions
      SET question_text_es = REPLACE(question_text_es, 'envase', 'recipiente/envase')
      WHERE question_text_es ILIKE '%envase%';
    SQL


    execute <<~SQL
      UPDATE options
      SET name_es = REPLACE(name_es, 'envases', 'recipientes/envases')
      WHERE name_es ILIKE '%envases%';
    SQL

    execute <<~SQL
      UPDATE options
      SET name_es = REPLACE(name_es, 'envase', 'recipiente/envase')
      WHERE name_es ILIKE '%envase%';
    SQL

  end
end
