# frozen_string_literal: true

module Api
  module V1
    module Houses
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            required(:reference_code).maybe(:string)
            optional(:address).maybe(:string)
            optional(:latitude).maybe(:float)
            optional(:longitude).maybe(:float)
            optional(:country_id).maybe(:integer)
            optional(:state_id).maybe(:integer)
            optional(:city_id).maybe(:integer)
            optional(:neighborhood_id).maybe(:integer)
            optional(:wedge_id).maybe(:integer)
            optional(:house_block_id).maybe(:integer)
            optional(:special_place_id).maybe(:integer)
            optional(:team_id).maybe(:integer)
            optional(:notes).maybe(:string)
          end

          rule(:id) do
            key.failure(text: 'The House does not exist', predicate: :not_exists?) unless House.exists?(id: value)
          end

          rule(:country_id) do
            key.failure(text: 'The Country does not exist', predicate: :not_exists?) unless Country.exists?(id: value)
          end

          rule(:state_id, :country_id) do
            if values[:state_id] && values[:country_id] && !State.exists?(id: values[:state_id],
                                                                          country_id: values[:country_id])
              key.failure(text: 'The State does not belong to the Country')
            end
          end

          rule(:city_id, :state_id) do
            if values[:city_id] && values[:state_id] && !City.exists?(id: values[:city_id], state_id: values[:state_id])
              key.failure(text: 'The City does not belong to the State')
            end
          end

          rule(:neighborhood_id, :city_id) do
            if values[:neighborhood_id] && values[:city_id] && !Neighborhood.exists?(id: values[:neighborhood_id],
                                                                                     city_id: values[:city_id])
              key.failure(text: 'The Neighborhood does not belong to the City')
            end
          end

          rule(:wedge_id, :neighborhood_id) do
            if values[:wedge_id] && values[:neighborhood_id] && !NeighborhoodWedge.exists?(wedge_id: values[:wedge_id],
                                                                                           neighborhood_id: values[:neighborhood_id])
              key.failure(text: 'The Wedge does not belong to the Neighborhood')
            end
          end

          rule(:house_block_id, :wedge_id) do
            if values[:house_block_id] && values[:wedge_id] && !HouseBlockWedge.exists?(
              house_block_id: values[:house_block_id], wedge_id: values[:wedge_id]
            )
              key.failure(text: 'The HouseBlock does not belong to the Wedge')
            end
          end

          rule(:special_place_id) do
            if value && !SpecialPlace.exists?(id: value)
              key.failure(text: 'The SpecialPlace does not exist',
                          predicate: :not_exists?)
            end
          end
        end
      end
    end
  end
end
