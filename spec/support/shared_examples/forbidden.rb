# frozen_string_literal: true

RSpec.shared_examples 'forbidden' do
  it 'returns forbidden status' do
    expect(response).to be_forbidden
    expect(response.body).to be_empty
  end
end
