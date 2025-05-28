class AddPositionToOptions < ActiveRecord::Migration[7.1]
  def change
    add_column :options, :position, :integer


    Question.all.each do |question|
      question.options.each_with_index do |option, index|
        option.update_column :position, index + 1
      end
    end
  end
end
