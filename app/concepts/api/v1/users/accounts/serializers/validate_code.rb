
# frozen_string_literal: true

module Api
  module V1
    module Users
      module Accounts
        module Serializers
          class ValidateCode
            include Alba::Resource
            transform_keys :lower_camel



            attributes :url do
              "url.url"
            end

          end
        end
      end
    end
  end
end
