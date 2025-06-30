class ChangeNoTieneTapaOptionValue < ActiveRecord::Migration[7.1]
  def change
    option = Option.find_by_name_es('No tiene tapa')
    if option
      option.disable_other_options = false
      option.save!
    end
  end
end
