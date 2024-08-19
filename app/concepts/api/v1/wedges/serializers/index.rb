# frozen_string_literal: true

module Api
  module V1
    module Wedges
      module Serializers
        class Index < ApplicationSerializer
          set_type :wedge

          attributes :name
        end
      end
    end
  end
end
