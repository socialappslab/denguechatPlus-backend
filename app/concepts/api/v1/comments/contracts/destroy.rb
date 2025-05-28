# frozen_string_literal: true
require 'ostruct'

module Api
  module V1
    module Comments
      module Contracts
        class Destroy < Dry::Validation::Contract

          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
          end

          rule(:id) do
            unless Comment.find_by(id: values[:id])
              key(:id).failure(text: 'Comment not found', predicate: :not_found?)
            end
          end

        end
      end
    end
  end
end
