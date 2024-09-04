module Api
  module V1
    module Cities
      module Serializers
        class ShowWithoutNeighborhoods < ApplicationSerializer
          set_type :city

          attributes :name
        end
      end
    end
  end
end
