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

    def self.send_approval_message(phone)
      client = new.client
      client.messages.create(
        from: ENV['TWILIO_PHONE_NUMBER'],
        to: phone,
        body: "Su usuario ha sido aprobado, ya puede utilizar la aplicación DengueChatPlus desde su celular."
      )
    end
  end
end
