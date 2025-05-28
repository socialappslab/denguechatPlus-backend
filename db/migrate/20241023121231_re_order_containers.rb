class ReOrderContainers < ActiveRecord::Migration[7.1]
  def up
    questionnaire = Questionnaire.last
    if questionnaire
      question = questionnaire.questions.where(question_text_es: '¿Qué tipo de contenedor encontraste?')&.first
      if question
        opts = question.options
        if opts
          non_permanents = opts.select { |t| t.group_es == 'No permanentes' }
          non_permanents.each_with_index { |option, index| option.update_column :position, index + 1 }

          last_non_permanent_position = non_permanents.size
          permanents = opts.select { |t| t.group_es == 'Permanentes' }
          permanents.each_with_index { |option, index| option.update_column :position, last_non_permanent_position + index + 1 }
        end
      end
    end
  end
end
