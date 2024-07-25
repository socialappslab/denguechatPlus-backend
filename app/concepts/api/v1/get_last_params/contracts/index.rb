# frozen_string_literal: true

module Api
  module V1
    module GetLastParams
      module Contracts
        class Index < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end
          params do
            optional(:name).maybe(:string, included_in?: Constants::VisitParams::RESOURCES)
          end
        end
      end
    end
  end
end
