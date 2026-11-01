# frozen_string_literal: true

module Api
  module V1
    module Avatars
      module Operations
        class Index < ApplicationOperation
          include Dry::Transaction

          step :list

          def list(_input)
            @ctx = { data: Avatar.catalog.with_attached_image }
            Success({ ctx: @ctx, type: :success })
          end
        end
      end
    end
  end
end
