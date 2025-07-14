# frozen_string_literal: true

require 'ostruct'

module Api
  module V1
    module Comments
      module Contracts
        class Create < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:user_account_id).filled(:integer)
            required(:post_id).filled(:integer)
            required(:content).filled(:string, min_size?: 1, max_size?: 280)
            optional(:photo)
          end

          rule(:user_account_id) do
            unless UserAccount.find_by(id: values[:user_account_id])
              key(:user_account_id).failure(text: 'the user not exist', predicate: :not_found?)
            end
          end

          rule(:post_id) do
            unless Post.find_by(id: values[:post_id])
              key(:user_account_id).failure(text: 'the post not exist', predicate: :not_found?)
            end
          end

          rule(:photo) do
            if values && !values[:photo].nil? && !values[:photo].is_a?(ActionDispatch::Http::UploadedFile)
              key(:photo).failure(text: 'must be an image') unless values[:photo].content_type.start_with?('image/')

              if values[:photo].size > 5_242_880
                key(:photo).failure(text: 'is too big, must be less than 5MB',
                                    predicate: :unique?)
              end
            end
          end
        end
      end
    end
  end
end
