class AddStatusToHouseStatus < ActiveRecord::Migration[7.1]
  def change
    # Agregar la columna `status` si no existe
    add_column :house_statuses, :status, :string unless column_exists?(:house_statuses, :status)

    HouseStatus.reset_column_information
    HouseStatus.find_each do |house_status|
      if house_status.infected_containers && house_status.infected_containers > 0
        house_status.update(status: 'red')
      elsif house_status.infected_containers.nil? || (house_status.infected_containers.zero? && house_status.potential_containers && house_status.potential_containers > 0)
        house_status.update(status: 'yellow')
      else
        house_status.update(status: 'green')
      end
    end
  end
end
