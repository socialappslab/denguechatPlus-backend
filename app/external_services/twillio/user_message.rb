# frozen_string_literal: true

require 'twilio-ruby'
module ExternalServices
  class Twillio::UserMessage < Twillio::Connection
    def self.send_recovery_code(phone, code)
      client = new.client
      client.messages.create(
        from: ENV['TWILIO_PHONE_NUMBER'],
        to: phone,
        body: "Tu código de recuperación es #{code} válido por 15 minutos."
      )
    end
  end
end
