class ChangeStructureToQuestion < ActiveRecord::Migration[7.1]
  class Question < ApplicationRecord
    has_one_attached :image
  end

  def change
    remove_index :questions, :parent_id, if_exists: true
    remove_column :questions, :parent_id, :integer
    add_column :questions, :additional_data, :jsonb, default: {}, null: false

    reversible do |dir|
      dir.up do
        Question.reset_column_information
        host_url = ENV["HOST_URL"] || "http://localhost:3000"

        splash_question = Question.find_by(question_text_es: 'Visitemos la casa')
        question = Question.find_by(question_text_es: '¿Me dieron permiso para visitar la casa?')


        if question
          question.update_column(:additional_data, {
            title: "Visitemos la casa",
            description: "Lleguemos a la casa con mucho respeto."
          })
          splash_question.update_column(:visible, false)
        end
      end
    end
  end
end
