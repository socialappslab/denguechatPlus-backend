class FixCunaOfTeam < ActiveRecord::Migration[7.1]
  def up
    teams = Team.all
    teams.each do |team|
      next unless team.sector

      wedge_id = team.wedge_id
      wedges_ids_of_current_sector = team.sector.wedge_ids
      unless wedges_ids_of_current_sector.include? wedge_id
        next unless wedges_ids_of_current_sector.include? team.wedge_id
        team.wedge_id = wedges_ids_of_current_sector.sample
        team.save!
      end
    end
  end
end
