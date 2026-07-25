# frozen_string_literal: true

require 'spec_helper'

RSpec.describe House do
  describe '#tariki?' do
    let(:reference_time) { Time.zone.parse('2026-07-20 18:00') }
    let(:suffix) { SecureRandom.hex(4) }
    let(:country) { Country.create!(name: "Country #{suffix}") }
    let(:state) { State.create!(name: "State #{suffix}", country:) }
    let(:city) { City.create!(name: "City #{suffix}", country:, state:) }
    let(:wedge) { Wedge.create!(name: "Wedge #{suffix}") }
    let(:neighborhood) do
      Neighborhood.create!(name: "Neighborhood #{suffix}", country:, state:, city:, wedge_id: wedge.id)
    end
    let(:organization) { Organization.create!(name: "Organization #{suffix}") }
    let(:team) do
      Team.create!(name: "Team #{suffix}", organization:, sector: neighborhood, wedge:)
    end
    let(:user_account) do
      UserAccount.create!(username: "user_#{suffix}", password: 'Password1', password_confirmation: 'Password1')
    end
    let(:questionnaire) { Questionnaire.create!(name: "Questionnaire #{suffix}") }
    let(:house) do
      described_class.create!(
        reference_code: "house_#{suffix}",
        country:,
        state:,
        city:,
        neighborhood:,
        wedge:
      )
    end

    def create_visit(status:, visited_at:)
      Visit.create!(house:, user_account:, team:, questionnaire:, status:, visited_at:)
    end

    it 'uses only the latest visit from each day' do
      create_visit(status: Constants::RiskColor::GREEN, visited_at: reference_time - 3.days)
      create_visit(status: Constants::RiskColor::GREEN, visited_at: reference_time - 2.days)
      create_visit(status: Constants::RiskColor::GREEN, visited_at: reference_time - 1.day)
      create_visit(status: Constants::RiskColor::GREEN, visited_at: reference_time.change(hour: 9))
      create_visit(status: Constants::RiskColor::RED, visited_at: reference_time.change(hour: 16))

      house.update!(status: Constants::RiskColor::RED)

      expect(house.tariki?(reference_time:)).to be(false)
      expect(house.consecutive_green_status_calculation(reference_time:)).to eq(0)
    end

    it 'requires all four distinct visit days to be inside the two-month window' do
      create_visit(status: Constants::RiskColor::GREEN, visited_at: reference_time - 2.months - 1.day)
      create_visit(status: Constants::RiskColor::GREEN, visited_at: reference_time - 3.days)
      create_visit(status: Constants::RiskColor::GREEN, visited_at: reference_time - 2.days)
      create_visit(status: Constants::RiskColor::GREEN, visited_at: reference_time - 1.day)

      house.update!(status: Constants::RiskColor::GREEN)

      expect(house.tariki?(reference_time:)).to be(false)
    end
  end
end
