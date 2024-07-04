# frozen_string_literal: true

Dry::Validation::Contract.config.messages.backend = :i18n

Dry::Validation.register_macro(:timezone?) do
  next unless value

  key.failure(:timezone?) unless ActiveSupport::TimeZone.all.any? { |timezone| timezone.name == value }
end

Dry::Validation.register_macro(:user_profile_exists?) do
  key.failure(:user_profile_exists?) unless UserProfile.exists?(id: value)
end

Dry::Validation.register_macro(:date_range?) do
  next unless key?(:filter)

  start_date, end_date = value

  key(filter: :start_date).failure(:date_range?) if start_date.present? && end_date.present? && start_date > end_date
end

Dry::Validation.register_macro(:pagination_direction?) do
  next unless key?(:page)
  next if !key?(page: :after) && !key?(page: :before)

  before = values[:page][:before]
  after = values[:page][:after]

  next if after.nil? && before.nil?
  next if (after.present? && before.blank?) || (after.blank? && before.present?)

  key(:page).failure(:pagination_direction?)
end

Dry::Validation.register_macro(:username_exists?) do
  if values[:type].eql?('username') && values[:username].nil?
    key.failure(:user_credential_requirement?)
  end
end

Dry::Validation.register_macro(:email_regex?) do
  key.failure(:email_regex?) unless value.match? Constants::Shared::EMAIL_REGEX
end
