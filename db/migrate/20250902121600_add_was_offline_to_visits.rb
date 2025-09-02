# frozen_string_literal: true

class AddWasOfflineToVisits < ActiveRecord::Migration[7.1]
  def change
    # Not enforcing false as default because we don't want to mark all visits
    # like they were synced online by default, we don't know that.
    add_column :visits, :was_offline, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
