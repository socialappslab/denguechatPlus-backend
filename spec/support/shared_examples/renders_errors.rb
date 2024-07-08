# frozen_string_literal: true

RSpec.shared_examples 'renders errors' do
  it 'renders errors' do
    expect(response).to be_unprocessable
    expect(response).to match_json_schema('errors')
  end
end

RSpec.shared_examples 'renders errors with meta' do
  it 'renders errors with meta' do
    expect(response).to be_unprocessable
    expect(response).to match_json_schema('errors_with_meta')
  end
end
