# frozen_string_literal: true

RSpec.describe Api::V1::Lib::Serializers::Errors::Reform do
  subject(:serializer) { described_class.new(messages) }

  context 'with 0 depth' do
    let(:messages) { { recurring_availabilities: ['must be unique by day', 'must be valid'] } }
    let(:expected_hash) do
      {
        errors: [
          {
            detail: 'must be unique by day',
            source: {
              pointer: '/data/attributes/recurring-availabilities'
            }
          },
          {
            detail: 'must be valid',
            source: {
              pointer: '/data/attributes/recurring-availabilities'
            }
          }
        ]
      }
    end

    it_behaves_like 'serializer'
  end

  context 'with 1 depth: array' do
    let(:messages) { { recurring_availabilities: [[0, ['must be a hash', 'must be valid']], [1, ['must be valid']]] } }
    let(:expected_hash) do
      {
        errors: [
          {
            detail: 'must be a hash',
            source: {
              pointer: '/data/attributes/recurring-availabilities/0'
            }
          },
          {
            detail: 'must be valid',
            source: {
              pointer: '/data/attributes/recurring-availabilities/0'
            }
          },
          {
            detail: 'must be valid',
            source: {
              pointer: '/data/attributes/recurring-availabilities/1'
            }
          }
        ]
      }
    end

    it_behaves_like 'serializer'
  end

  context 'with 2 depth: array-hash' do
    let(:messages) do
      {
        recurring_availabilities: [
          [0, { times: ['must be an array', 'must not intersect'], day: ['must be filled'] }],
          [1, { day: ['must be filled'] }]
        ]
      }
    end
    let(:expected_hash) do
      {
        errors: [
          {
            detail: 'must be an array',
            source: {
              pointer: '/data/attributes/recurring-availabilities/0/times'
            }
          },
          {
            detail: 'must not intersect',
            source: {
              pointer: '/data/attributes/recurring-availabilities/0/times'
            }
          },
          {
            detail: 'must be filled',
            source: {
              pointer: '/data/attributes/recurring-availabilities/0/day'
            }
          },
          {
            detail: 'must be filled',
            source: {
              pointer: '/data/attributes/recurring-availabilities/1/day'
            }
          }
        ]
      }
    end

    it_behaves_like 'serializer'
  end

  context 'with 1 depth: hash' do
    let(:messages) do
      {
        page: [
          [:number, ['must be an integer']],
          [:size, ['must be an integer', 'must be greater than or equal to 1']]
        ]
      }
    end
    let(:expected_hash) do
      {
        errors: [
          {
            detail: 'must be an integer',
            source: {
              pointer: '/data/attributes/page/number'
            }
          },
          {
            detail: 'must be an integer',
            source: {
              pointer: '/data/attributes/page/size'
            }
          },
          {
            detail: 'must be greater than or equal to 1',
            source: {
              pointer: '/data/attributes/page/size'
            }
          }
        ]
      }
    end

    it_behaves_like 'serializer'
  end

  context 'with 4 depth: array-hash-array-hash' do
    let(:messages) do
      {
        recurring_availabilities: [
          [
            0, {
              day: ['must be a string'],
              times: {
                0 => {
                  start: [
                    'must be an integer',
                    'must be greater than or equal to 0'
                  ],
                  duration: [
                    'must be an integer'
                  ]
                }
              }
            }
          ]
        ]
      }
    end
    let(:expected_hash) do
      {
        errors: [
          {
            detail: 'must be a string',
            source: {
              pointer: '/data/attributes/recurring-availabilities/0/day'
            }
          },
          {
            detail: 'must be an integer',
            source: {
              pointer: '/data/attributes/recurring-availabilities/0/times/0/start'
            }
          },
          {
            detail: 'must be greater than or equal to 0',
            source: {
              pointer: '/data/attributes/recurring-availabilities/0/times/0/start'
            }
          },
          {
            detail: 'must be an integer',
            source: {
              pointer: '/data/attributes/recurring-availabilities/0/times/0/duration'
            }
          }
        ]
      }
    end

    it_behaves_like 'serializer'
  end
end
