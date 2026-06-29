# frozen_string_literal: true

module HasRiskColor
  extend ActiveSupport::Concern

  class_methods do
    def risk_color_enum(attribute, allow_nil: false)
      options = {
        Constants::RiskColor::GREEN.to_sym => Constants::RiskColor::GREEN,
        Constants::RiskColor::YELLOW.to_sym => Constants::RiskColor::YELLOW,
        Constants::RiskColor::RED.to_sym => Constants::RiskColor::RED
      }

      enum_options = allow_nil ? { validate: { allow_nil: true } } : {}
      enum attribute, options, **enum_options
    end
  end
end
