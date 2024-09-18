

module Api
  module V1
    module GetAddress
      module Decorators
        class AddressDecorator

          AddressStruct = Struct.new(:address)

          def self.call(*args)
            new.call(*args)
          end

          def call(*args)
            return AddressStruct.new(address: '') if   args.flatten.nil? || args.flatten.empty?

            AddressStruct.new(address: args.first.address)
          end
        end
      end
    end
  end
end
