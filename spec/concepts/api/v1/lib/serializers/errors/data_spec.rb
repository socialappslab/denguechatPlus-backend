# frozen_string_literal: true

RSpec.describe Api::V1::Lib::Serializers::Errors::Data do
  subject(:serializer) { described_class.new(field, message, title, meta).data }

  let(:field) { 'test' }
  let(:message) { FFaker::Lorem.sentence }
  let(:title) { nil }
  let(:meta) { nil }

  let(:base_result) do
    {
      detail: message,
      source: {
        pointer: '/data/attributes/test'
      }
    }
  end

  it { is_expected.to eq(base_result) }

  context 'with title' do
    let(:title) { FFaker::Lorem.word }
    let(:result) { base_result.merge(title:) }

    it { is_expected.to eq(result) }
  end

  context 'with meta' do
    let(:meta) { { type: :test } }
    let(:result) { base_result.merge(meta:) }

    it { is_expected.to eq(result) }
  end
end
