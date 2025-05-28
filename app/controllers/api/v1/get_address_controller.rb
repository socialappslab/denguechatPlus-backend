# frozen_string_literal: true

module Api
  module V1
    class GetAddressController < AuthorizedApiController
      def find_address
        endpoint operation: Api::V1::GetAddress::Operations::FindAddress,
                 renderer_options: { serializer: Api::V1::GetAddress::Serializers::Show },
                 options: { current_user: }
      end
    end
  end
end
