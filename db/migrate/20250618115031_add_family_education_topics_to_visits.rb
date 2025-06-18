class AddFamilyEducationTopicsToVisits < ActiveRecord::Migration[7.1]
  def change
    add_column :visits, :family_education_topics, :string, array: true, default: [], null: true
  end
end
