# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::V1::Visits::Serializers::Show do
  describe 'pointAwards' do
    subject(:point_awards) do
      serialized = described_class.new(visit, fields: { visit: [:pointAwards] }).serializable_hash
      serialized.dig(:data, :attributes, :pointAwards)
    end

    let(:visit) { instance_double(Visit, id: 7, point_awards: points) }
    let(:points) do
      [
        instance_double(Point, pointable_type: 'UserAccount', value: 10),
        instance_double(Point, pointable_type: 'Team', value: 20)
      ]
    end

    it 'serializes persisted points as Tariki awards' do
      expect(point_awards).to eq(
        [
          { recipient: 'brigadist', amount: 10, reason: 'tariki_reached' },
          { recipient: 'brigade', amount: 20, reason: 'tariki_reached' }
        ]
      )
    end

    context 'when the visit did not create points' do
      let(:points) { [] }

      it { is_expected.to eq([]) }
    end
  end
end
