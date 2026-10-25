# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::V1::HouseBlocks::Operations::Create do
  subject(:result) { described_class.call(params:) }

  let(:country) { Country.create!(name: 'Peru') }
  let(:state) { State.create!(name: 'Loreto', country:) }
  let(:city) { City.create!(name: 'Iquitos', state:, country:) }
  let(:neighborhood) { Neighborhood.create!(name: 'Sector 1', country:, state:, city:) }
  let(:wedge) { Wedge.create!(name: 'Cuna 1') }
  let(:house) do
    House.create!(reference_code: 'TA001', country:, state:, city:, neighborhood:, wedge:,
                  assignment_status: :orphaned)
  end
  let(:params) do
    { 'name' => 'Block 1', 'wedgeId' => wedge.id, 'houseIds' => [house.id], 'blockType' => 'block' }
  end

  it 'creates the house block in the wedge with its houses assigned' do
    expect(result).to be_success

    house_block = result.value![:ctx][:model]
    expect(house_block.reload.wedges).to contain_exactly(wedge)
    expect(house_block.houses).to contain_exactly(house)
    expect(house.reload).to be_assigned
  end
end
