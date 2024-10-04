class AddLastVisitCountersForStatusesToHouse < ActiveRecord::Migration[7.1]
  def change
    add_column :houses, :last_visit, :datetime
    add_column :houses, :infected_containers, :integer
    add_column :houses, :non_infected_containers, :integer
    add_column :houses, :potential_containers, :integer
  end
end
