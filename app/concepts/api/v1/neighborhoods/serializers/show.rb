module Api
  module V1
    module Neighborhoods
      module Serializers
        class Show < ApplicationSerializer
          set_type :neighborhood

          attributes :name
        end
      end
    end
  end
end
