# frozen_string_literal: true

RSpec.configure do |config|
  if Bullet.enable?
    config.before(:each, type: :request) do
      Bullet.start_request
    end

    config.after(:each, type: :request) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end
