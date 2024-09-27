class FillLocationPost < ActiveRecord::Migration[7.1]
  def up
    Post.includes(team: { sector: :city }).find_each do |post|
      sector_name = post.team.sector.name
      city_name   = post.team.sector.city.name
      post.update(location: "#{sector_name}, #{city_name}")
    end
  end
end
