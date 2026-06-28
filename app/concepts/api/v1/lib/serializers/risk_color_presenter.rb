# frozen_string_literal: true

module Api
  module V1
    module Lib
      module Serializers
        module RiskColorPresenter
          module_function

          def display(color, locale: I18n.locale)
            return color if color.blank? || Constants::RiskColor::ALL.exclude?(color.to_s)

            I18n.t("visits.colors.#{color}", locale: locale)
          end
        end
      end
    end
  end
end
