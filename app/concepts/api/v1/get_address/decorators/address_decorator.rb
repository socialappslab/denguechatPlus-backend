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

            res_address = google_api_results.find do |result|
              result.data['address_components'].any? do |component|
                component['types'].include?('route')
              end
            end
            res_address = google_api_results.first.address if res_address.nil?
            AddressStruct.new(address: res_address.address.split(',').first) if res_address.present?
          end
        end
      end
    end
  end
end
