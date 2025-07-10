# frozen_string_literal: true

require 'ostruct'

module Api
  module V1
    module Posts
      module Contracts
        class Destroy < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
          end

          rule(:id) do
            key(:id).failure(text: 'Post not found', predicate: :not_found?) unless Post.find_by(id: values[:id])
          end
        end
      end
    end
  end
end
