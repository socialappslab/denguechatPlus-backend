# frozen_string_literal: true

module Api
  module V1
    module Comments
      module Contracts
        class Like < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            required(:post_id).filled(:integer)
            required(:comment_id).filled(:integer)

            optional(:page).maybe(:hash) do
              optional(:is_cursor).maybe(:bool)
            end

            optional(:sort).maybe(:string)
          end

          rule(:post_id) do
            unless Post.find_by(id: values[:post_id])
              key(:post_id).failure(text: 'the post not exist', predicate: :not_found?)
            end
          end

          rule(:comment_id) do
            unless Comment.find_by(id: values[:comment_id])
              key(:comment_id).failure(text: 'the comment not exist', predicate: :not_found?)
            end
          end
        end
      end
    end
  end
end
