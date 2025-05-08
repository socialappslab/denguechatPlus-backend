# app/workers/lock_account_worker.rb

module Reports
  class HouseStatus
    include Sidekiq::Worker

    def perform
      statuses_to_insert = []
      House.all.find_each do |house|
        statuses_to_insert << {
          date: Time.zone.today,
          infected_containers: house.infected_containers,
          non_infected_containers: house.non_infected_containers,
          potential_containers: house.potential_containers,
          house_id: house.id,
          city_id: house.city_id,
          country_id: house.country_id,
          house_block_id: house.house_block_id,
          neighborhood_id: house.neighborhood_id,
          team_id: house.team_id,
          wedge_id: house.wedge_id,
          last_visit: house.last_visit
        }

        if statuses_to_insert.size >= 1000
          HouseStatus.insert_all(statuses_to_insert)
          statuses_to_insert.clear
        end
      end

      ::HouseStatus.insert_all(statuses_to_insert) if statuses_to_insert.any?
    end
  end
end
