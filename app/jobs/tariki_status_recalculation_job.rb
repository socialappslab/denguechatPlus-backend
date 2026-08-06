# frozen_string_literal: true

class TarikiStatusRecalculationJob < ApplicationJob
  queue_as :default

  def perform
    Services::TarikiStatusRecalculator.call
  end
end
