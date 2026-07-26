# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::V1::GetLastParams::Queries::Index do
  describe '.call' do
    it 'does not expose backend app configuration to mobile' do
      resource_names = described_class.call(nil).map(&:resource_name)

      expect(resource_names).not_to include('AppConfigParam')
    end
  end
end
