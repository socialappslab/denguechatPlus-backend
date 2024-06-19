# frozen_string_literal: true

module Api
  module V1
    module Users
      module Lib
        class CheckAccountActive
          def self.call(_ctx, model:, **)
            !model.discarded?
          end
        end
      end
    end
  end
end
