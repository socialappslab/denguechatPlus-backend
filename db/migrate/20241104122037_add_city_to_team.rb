class AddCityToTeam < ActiveRecord::Migration[7.1]
  def change
    add_reference :teams, :city, null: true, foreign_key: true
  end
end
