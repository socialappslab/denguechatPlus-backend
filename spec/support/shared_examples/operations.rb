# frozen_string_literal: true

shared_examples 'operation success' do
  it 'operation is success' do
    expect(result).to be_success
  end
end

shared_examples 'operation failure' do
  it 'operation is failure' do
    expect(result).to be_failure
  end
end
