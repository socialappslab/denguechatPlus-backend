# frozen_string_literal: true
require 'ostruct'

module Api
  module V1
    module Posts
      module Contracts
        class Create < Dry::Validation::Contract

          def self.kall(...)
            new.call(...)
          end

          params do
            required(:user_account_id).filled(:integer)
            required(:content).filled(:string, min_size?: 5, max_size?: 500)
            optional(:photos).filled(:array)
          end

          rule(:user_account_id) do
            user = UserAccount.find_by(id: values[:user_account_id])

            unless user
              key(:user_account_id).failure(text: 'the user has not exist', predicated: :not_found?)
            end

            unless user&.teams&.any?
              key(:user_account_id).failure(text: 'the user has no team assigned', predicated: :not_found?)
            end

            unless user&.city_id
              key(:user_account_id).failure(text: 'the user has no city assigned', predicated: :not_found?)
            end

            unless user&.neighborhood_id
              key(:user_account_id).failure(text: 'the user has no sector assigned', predicated: :not_found?)
            end

            if Neighborhood.find_by(id: user&.neighborhood_id)&.country.nil?
              key(:user_account_id).failure(text: 'the user has no country assigned', predicated: :not_found?)
            end

          end

          rule(:photos) do
            if values[:photos]
              unless values[:photos].all? { |photo| photo.content_type.start_with?('image/') }
                key(:photos).failure(text: 'must be an image')
              end

              if values[:photos].size > 5
                key(:photos).failure(text: 'cannot have more than 5 attachments',
                                     predicate: :unique?)
              end

              values[:photos].each do |photo|
                if photo.size > 5_242_880
                  key(:photos).failure(text: 'is too big, must be less than 5MB',
                                       predicate: :unique?)
                end
              end
            end
          end
        end
      end
    end
  end
end
