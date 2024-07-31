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

module Dry
  module Validation
    class Contract

      attr_reader :data_entry

      def call(input, context = EMPTY_HASH)
        input = transform_params(input)
        context_map = Concurrent::Map.new.tap do |map|
          default_context.each { |key, value| map[key] = value }
          context.each { |key, value| map[key] = value }
        end
        Result.new(schema.(input), context_map) do |result|
          rules.each do |rule|
            next if rule.keys.any? { |key| error?(result, key) }

            rule_result = rule.(self, result)

            rule_result.failures.each do |failure|
              result.add_error(message_resolver.(**failure))
            end
          end

        end
      end

      private

      def transform_params(params)
        return params if params.nil? || params[:action].nil? || params[:action].blank?
        return params if params.nil? || params[:action] != 'update'

        result = {}
        if params[:action] == 'update' && params[:id]
          key = params[:controller].split('/').last.singularize
          result = params[key]
          result[:id] = params[:id]
        else
          result = params
        end
        result
      end
    end
  end
end
