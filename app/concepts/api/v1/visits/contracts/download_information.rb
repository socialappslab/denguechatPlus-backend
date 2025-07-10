# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Contracts
        class DownloadInformation < Dry::Validation::Contract
          def self.kall(...)
            new.call(...)
          end

          params do
            required(:id).filled(:integer)
          end
        end
      end
    end
  end
end
