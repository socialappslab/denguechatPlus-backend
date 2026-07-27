# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::V1::Inspections::Contracts::Create do
  subject(:result) { described_class.kall(params) }

  let(:params) do
    {
      visit_id: '12',
      breeding_site_type_id: '3',
      location: 'house',
      container_protection_ids: %w[1 2],
      elimination_method_type_ids: ['4'],
      type_content_ids: ['5'],
      water_source_type_ids: ['6']
    }
  end

  before do
    allow(BreedingSiteType).to receive(:exists?).with(id: 3).and_return(true)
    stub_existing_ids(ContainerProtection, 2)
    stub_existing_ids(EliminationMethodType, 1)
    stub_existing_ids(TypeContent, 1)
    stub_existing_ids(WaterSourceType, 1)
  end

  it 'accepts and coerces a valid container payload' do
    expect(result).to be_success
    expect(result.to_h).to include(
      visit_id: 12,
      breeding_site_type_id: 3,
      container_protection_ids: [1, 2]
    )
  end

  context 'when a related resource does not exist' do
    before do
      stub_existing_ids(ContainerProtection, 1)
    end

    it 'returns a validation error' do
      expect(result).to be_failure
      expect(result.errors.map(&:path)).to include([:container_protection_ids])
    end
  end

  context 'when the location is invalid' do
    let(:params) { super().merge(location: 'roof') }

    it 'returns a validation error' do
      expect(result).to be_failure
      expect(result.errors.map(&:path)).to include([:location])
    end
  end

  def stub_existing_ids(model, count)
    relation = instance_double(ActiveRecord::Relation, count:)
    allow(model).to receive(:where).and_return(relation)
  end
end
