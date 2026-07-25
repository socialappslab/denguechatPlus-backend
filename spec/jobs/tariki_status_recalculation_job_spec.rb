# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TarikiStatusRecalculationJob do
  it 'recalculates persisted Tariki statuses' do
    allow(Services::TarikiStatusRecalculator).to receive(:call)

    described_class.perform_now

    expect(Services::TarikiStatusRecalculator).to have_received(:call)
  end
end
