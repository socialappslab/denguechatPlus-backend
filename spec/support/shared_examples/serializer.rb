# frozen_string_literal: true

RSpec.shared_examples 'serializer' do
  describe '#serializable_hash' do
    it 'returns serializeble hash' do
      expect(serializer.serializable_hash).to eq(expected_hash)
    end
  end

  describe '#serialized_json' do
    let(:expected_json) { JSON(expected_hash) }

    it 'returns serialized json' do
      expect(serializer.serialized_json).to eq expected_json
    end
  end
end
