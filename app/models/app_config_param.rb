# frozen_string_literal: true

# == Schema Information
#
# Table name: app_config_params
#
#  id           :bigint           not null, primary key
#  description  :string
#  discarded_at :datetime
#  name         :string
#  param_source :string
#  param_type   :string
#  value        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_app_config_params_on_name                   (name) UNIQUE
#  index_app_config_params_on_param_source_and_name  (param_source,name)
#
class AppConfigParam < ApplicationRecord
  include Discard::Model

  TARIKI_REQUIRED_GREEN_VISITS_NAME = 'consecutive_green_statuses_for_tariki_house'
  TARIKI_TIME_WINDOW_MONTHS_NAME = 'tariki_status_time_window_months'
  TARIKI_CALCULATION_PARAM_NAMES = [
    TARIKI_REQUIRED_GREEN_VISITS_NAME,
    TARIKI_TIME_WINDOW_MONTHS_NAME
  ].freeze

  DEFAULT_TARIKI_REQUIRED_GREEN_VISITS = 4
  DEFAULT_TARIKI_TIME_WINDOW_MONTHS = 2

  validate :tariki_calculation_value_must_be_a_positive_integer

  after_commit :enqueue_tariki_status_recalculation, on: %i[create update], if: :tariki_calculation_value_changed?

  def self.tariki_required_green_visits
    positive_integer_value(TARIKI_REQUIRED_GREEN_VISITS_NAME, DEFAULT_TARIKI_REQUIRED_GREEN_VISITS)
  end

  def self.tariki_time_window
    positive_integer_value(TARIKI_TIME_WINDOW_MONTHS_NAME, DEFAULT_TARIKI_TIME_WINDOW_MONTHS).months
  end

  def self.positive_integer_value(name, default)
    value = Integer(kept.find_by(name:)&.value, exception: false)
    value&.positive? ? value : default
  end
  private_class_method :positive_integer_value

  private

  def tariki_calculation_value_changed?
    saved_change_to_value? && name.in?(TARIKI_CALCULATION_PARAM_NAMES)
  end

  def tariki_calculation_value_must_be_a_positive_integer
    return unless name.in?(TARIKI_CALCULATION_PARAM_NAMES)

    parsed_value = Integer(value, exception: false)
    errors.add(:value, 'must be a positive integer') unless parsed_value&.positive?
  end

  def enqueue_tariki_status_recalculation
    TarikiStatusRecalculationJob.perform_later
  end
end
