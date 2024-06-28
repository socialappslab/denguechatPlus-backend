# frozen_string_literal: true

RSpec.describe Api::V1::Lib::Serializers::Errors::Hash do
  subject(:serializer) { described_class.new(messages) }

  let(:meta) { { type: :availabilities } }
  let(:messages) do
    [{
      field: :recurring_availabilities,
      messages: ['must be unique by day', 'must be valid'],
      title: 'Availabilities',
      meta:
    }]
  end

  let(:expected_hash) do
    {
      errors: [
        {
          detail: 'must be unique by day',
          title: 'Availabilities',
          meta:,
          source: {
            pointer: '/data/attributes/recurring-availabilities'
          }
        },
        {
          detail: 'must be valid',
          title: 'Availabilities',
          meta:,
          source: {
            pointer: '/data/attributes/recurring-availabilities'
          }
        }
      ]
    }
  end

  it_behaves_like 'serializer'
end
