# frozen_string_literal: true

module Api
  module V1
    module Organizations
      module Serializers
        class ShowA < ActiveModel::Serializer
          attributes :id, :name


          def model_name
            object.class.model_name
          end


        end
      end
    end
  end
end
