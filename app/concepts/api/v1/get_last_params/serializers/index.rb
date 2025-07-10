# frozen_string_literal: true

module Api
  module V1
    module GetLastParams
      module Serializers
        class Index
          include Alba::Resource
          transform_keys :lower_camel

          attributes :id, :version, :resource_name, :resource_data
        end
      end
    end
  end
end
