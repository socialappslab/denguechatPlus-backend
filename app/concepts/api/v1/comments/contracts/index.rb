# frozen_string_literal: true

module Api
  module V1
    module Comments
      module Contracts
        class Index < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            required(:post_id).filled(:integer)

            optional(:page).maybe(:hash) do
              optional(:is_cursor).maybe(:bool)
            end

            optional(:sort).maybe(:string)
          end

          rule(:post_id) do
            unless Post.find_by(id: values[:post_id])
              key(:user_account_id).failure(text: 'the post not exist', predicate: :not_found?)
            end
          end
        end
      end
    end
  end
end
