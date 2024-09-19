

module Api
  module V1
    module GetAddress
      module Decorators
        class AddressDecorator

          AddressStruct = Struct.new(:address)

          def self.call(google_api_results)
            new.call(google_api_results)
          end

          def call(google_api_results)
            return AddressStruct.new(address: nil) if google_api_results.flatten.blank?

            AddressStruct.new(address: google_api_results.first.address)
          end
        end
      end
    end
  end
end
