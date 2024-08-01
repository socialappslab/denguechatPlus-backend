# frozen_string_literal: true

module Api
  module V1
    module Neighborhoods
      module Serializers
        class Index < ApplicationSerializer
          set_type :neighborhood

          attributes :name

        end
      end
    end
  end
end
