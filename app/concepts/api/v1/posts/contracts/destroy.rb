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
            unless Post.find_by(id: values[:id])
              key(:id).failure(text: 'Post not found', predicate: :not_found?)
            end
          end

        end
      end
    end
  end
end
