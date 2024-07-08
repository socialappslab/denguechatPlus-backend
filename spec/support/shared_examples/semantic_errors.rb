# frozen_string_literal: true

RSpec.shared_examples 'semantic forbidden' do
  it 'sets failure_semantic to forbidden' do
    expect(result[:failure_semantic]).to eq(:forbidden)
    expect(result).to be_failure
  end
end
