# frozen_string_literal: true

require 'ostruct'

module Api
  module V1
    module Posts
      module Contracts
        class Update < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
            optional(:user_account_id).filled(:integer)
            optional(:content).filled(:string, min_size?: 1, max_size?: 280)
            optional(:photos).filled(:array)
            optional(:delete_photo).maybe(:bool)
          end

          rule(:id) do
            key(:id).failure(text: 'The post not exists', predicate: :not_found?) unless Post.find_by(id: values[:id])
          end

          rule(:user_account_id) do
            user = UserAccount.find_by(id: values[:user_account_id])

            key(:user_account_id).failure(text: 'the user has not exist', predicate: :not_found?) unless user

            unless user&.teams&.any?
              key(:user_account_id).failure(text: 'the user has no team assigned', predicate: :not_found?)
            end

            unless user&.city_id
              key(:user_account_id).failure(text: 'the user has no city assigned', predicate: :not_found?)
            end

            unless user&.neighborhood_id
              key(:user_account_id).failure(text: 'the user has no sector assigned', predicate: :not_found?)
            end

            if Neighborhood.find_by(id: user&.neighborhood_id)&.country.nil?
              key(:user_account_id).failure(text: 'the user has no country assigned', predicate: :not_found?)
            end
          end

          rule(:photos) do
            if values[:photos]

              unless values[:photos].all? { |photo| photo.is_a?(ActionDispatch::Http::UploadedFile) }
                key(:photos).failure(text: 'must be an image', predicate: :format?)
                next
              end

              unless values[:photos].all? { |photo| photo.content_type.start_with?('image/') }
                key(:photos).failure(text: 'must be an image', predicate: :format?)
                next
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
