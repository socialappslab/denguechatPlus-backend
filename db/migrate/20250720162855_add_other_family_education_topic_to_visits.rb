class AddOtherFamilyEducationTopicToVisits < ActiveRecord::Migration[7.1]
  def change
    add_column :visits, :other_family_education_topic, :string
  end
end
