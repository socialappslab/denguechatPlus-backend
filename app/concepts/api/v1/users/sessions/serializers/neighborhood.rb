# frozen_string_literal: true

module Api
  module V1
    module Users
      module Sessions
        module Serializers
          class Neighborhood < ApplicationSerializer
            set_type :neighborhood

            attributes  :name

          end
        end
      end
    end
  end
end