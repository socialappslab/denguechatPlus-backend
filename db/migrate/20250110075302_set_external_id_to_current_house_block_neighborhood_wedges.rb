class SetExternalIdToCurrentHouseBlockNeighborhoodWedges < ActiveRecord::Migration[7.1]
  def up
    Neighborhood.all.each do |neighborhood|
      next unless neighborhood.name.in?(['Sector 16 (Tupac Amaru)', 'Sector 4 (Maynas)'])

      neighborhood.external_id = neighborhood.name.split(' ').second.to_i
      neighborhood.save!
    end

    Wedge.all.each do |wedge|
      wedge.external_id = wedge.name.split(' ').last.to_i
      wedge.save!
    end

    HouseBlock.all.each do |hb|
      hb.external_id = hb.name.to_i
      hb.save!
    end
  end
end
