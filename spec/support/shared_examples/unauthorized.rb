# frozen_string_literal: true

RSpec.shared_examples 'unauthorized' do
  it 'breaches policy' do
    expect(result[:failure_semantic]).to eq(:forbidden)
    expect(result).to be_failure
  end
end
