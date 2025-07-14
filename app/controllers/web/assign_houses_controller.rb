module Web
  class AssignHousesController < ApplicationWebController
    skip_before_action :verify_authenticity_token, only: %i[list houses house_blocks sectors brigadists]
    before_action :http_authenticate

    # Retorna brigadistas en función al equipo (team)
    def brigadists
      team_id = params[:team_id]
      if team_id.present?
        @brigadists = UserProfile.joins(:team).where(team_id: team_id)
        render json: @brigadists.select(:id, :first_name, :last_name)
      else
        render json: { error: 'Team ID is required' }, status: :bad_request
      end
    end

    # Retorna sectores (neighborhoods) en función a la ciudad (city)
    def sectors
      city_id = params[:city_id]
      if city_id.present?
        @sectors = Neighborhood.where(city_id: city_id)
        render json: @sectors.select(:id, :name)
      else
        render json: { error: 'City ID is required' }, status: :bad_request
      end
    end

    # Retorna bloques de casas (house_blocks) en función al sector (neighborhood)
    def house_blocks
      neighborhood_id = params[:sector_id]
      if neighborhood_id.present?
        @house_blocks = HouseBlock.joins(:team).where(teams: { neighborhood_id: neighborhood_id })
        render json: @house_blocks.select(:id, :name)
      else
        render json: { error: 'Neighborhood ID is required' }, status: :bad_request
      end
    end

    # Retorna casas (houses) en función al bloque de casas (house_block)
    def houses
      house_block_id = params[:house_block_id]
      if house_block_id.present?
        @houses = House.where(house_block_id: house_block_id)
        render json: @houses.select(:id, :name, :address)
      else
        render json: { error: 'House Block ID is required' }, status: :bad_request
      end
    end

    # Lista equipos y ciudades para asignar casas
    def list
      @teams = Team.all
      @cities = City.all
      render 'assign_houses/list'
    end
  end
end
