# frozen_string_literal: true

RSpec.shared_examples 'has validation errors' do
  it 'has validation errors' do # rubocop:disable RSpec/NoExpectationExample
    match_validation_errors(result, errors)
  end
end
