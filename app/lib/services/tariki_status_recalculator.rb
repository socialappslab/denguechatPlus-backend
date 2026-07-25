# frozen_string_literal: true

module Services
  class TarikiStatusRecalculator
    def self.call
      updated_count = 0
      House.find_each { |house| updated_count += 1 if recalculate!(house) }
      updated_count
    end

    def self.recalculate!(house)
      updated = false

      house.with_lock do
        state = house.current_tariki_state(
          required_green_visits: AppConfigParam.tariki_required_green_visits,
          time_window: AppConfigParam.tariki_time_window
        )
        changes = state.reject { |attribute, value| house.public_send(attribute) == value }
        next if changes.empty?

        house.update_columns(**changes, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
        updated = true
      end

      updated
    end
  end
end
