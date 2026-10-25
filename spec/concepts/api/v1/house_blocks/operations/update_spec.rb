# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::V1::HouseBlocks::Operations::Update do
  subject(:result) { described_class.call(params:) }

  let(:old_wedge) { Wedge.create!(name: 'Cuna 1') }
  let(:new_wedge) { Wedge.create!(name: 'Cuna 2') }
  let(:house_block) { HouseBlock.create!(name: 'Block 1', block_type: 'block', wedges: [old_wedge]) }
  let(:params) { { 'id' => house_block.id, 'wedgeId' => new_wedge.id } }

  it 'moves the house block to the given wedge' do
    expect(result).to be_success
    expect(house_block.reload.wedges).to contain_exactly(new_wedge)
  end
end
