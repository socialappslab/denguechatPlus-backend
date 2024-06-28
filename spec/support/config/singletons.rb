# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all) do
    # It has to be created and reused over all specs (Singleton pattern)
  end
end
