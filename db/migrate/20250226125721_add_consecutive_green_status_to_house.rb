class AddConsecutiveGreenStatusToHouse < ActiveRecord::Migration[7.1]
  def up
    add_column :houses, :consecutive_green_status, :integer, default: 0

    House.find_each do |house|
      statuses = HouseStatus.where(house_id: house.id).order(created_at: :desc).pluck(:status)

      consecutive_count = 0
      if statuses.first == 'green'
        statuses.each do |status|
          break unless status == 'green'

          consecutive_count += 1
        end
      else
        consecutive_count = 0
      end

      house.update_column(:consecutive_green_status, consecutive_count)
    end
  end

  def down
    remove_column :houses, :consecutive_green_status
  end
end
