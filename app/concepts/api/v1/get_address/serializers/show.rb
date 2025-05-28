
# frozen_string_literal: true

module Api
  module V1
    module GetAddress
      module Serializers
        class Show
          include Alba::Resource
          transform_keys :lower_camel



          attributes :address

        end
      end
    end
  end
end
