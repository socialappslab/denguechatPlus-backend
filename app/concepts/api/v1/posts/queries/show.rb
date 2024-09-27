# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Queries
        class Show
          include Api::V1::Lib::Queries::QueryHelper

          def initialize(current_user, source, params)
            @model = @posts = Post.with_attached_photos.includes(:likes, user_account: :user_profile, comments: %i[user_account likes])
            @filter = filter
            @sort = sort
            @current_user = current_user
            @source = source
            @params = params || {}
          end

          def self.call(...)
            new(...).call
          end

          def call
            @model.yield_self(&method(:by_id))
                  .yield_self(&method(:like_by_me))
          end

          private

          attr_reader :posts, :filter, :sort

          def by_id(relation)
            return relation if @params.nil? || @params[:id].nil?

            relation.find(id: @params[:id])
          end



          def like_by_me(relation)
            return relation if @current_user.nil?

            relation.likes.exists?(user_account_id: current_user_id, likeable: true)
          end

        end
      end
    end
  end
end
