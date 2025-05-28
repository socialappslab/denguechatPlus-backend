# frozen_string_literal: true

require 'twilio-ruby'

module ExternalServices
  class Twillio::Connection
    attr_reader :client
    def initialize
      @client = Twilio::REST::Client.new ENV.fetch('TWILIO_SID', nil), ENV.fetch('TWILIO_TOKEN', nil)
    end
  end
end
