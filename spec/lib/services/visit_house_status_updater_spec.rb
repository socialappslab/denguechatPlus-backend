# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::VisitHouseStatusUpdater do
  describe '.apply_and_tariki_reached?' do
    let(:country) { Country.create!(name: 'Peru') }
    let(:state) { State.create!(name: 'Loreto', country:) }
    let(:city) { City.create!(name: 'Iquitos', state:, country:) }
    let(:neighborhood) { Neighborhood.create!(name: 'Sector 1', city:, state:, country:) }
    let(:wedge) { Wedge.create!(name: 'Wedge 1') }
    let(:team) do
      Team.create!(name: 'Team 1', organization: Organization.create!(name: 'Org'), sector: neighborhood, wedge:)
    end
    let(:user_account) { UserAccount.create!(username: 'brigadist', phone: '999000111', password: 'Password1') }
    let(:questionnaire) { Questionnaire.create!(name: 'Questionnaire', current_form: true) }
    let(:house) { create_house('MY293') }
    let(:other_house) { create_house('PUC323-324') }
    let(:morning) { Time.utc(2026, 10, 12, 13, 25) }
    let(:afternoon) { Time.utc(2026, 10, 12, 19, 40) }

    def create_house(reference_code)
      House.create!(country:, state:, city:, neighborhood:, wedge:, reference_code:)
    end

    def create_visit(visited_at, house: self.house)
      visit = Visit.create!(house:, team:, user_account:, questionnaire:, visited_at:)
      described_class.apply_and_tariki_reached?(visit:)
      visit
    end

    def daily_last_visits(house)
      HouseStatus.where(house_id: house.id).order(:date).pluck(:date, :last_visit)
    end

    it 'keeps the latest visit when an older one is created afterwards' do
      create_visit(afternoon)
      create_visit(morning)

      expect(house.reload.last_visit).to eq(afternoon)
      expect(daily_last_visits(house)).to eq([[Date.new(2026, 10, 12), afternoon]])
    end

    it 'keeps the latest visit when an older one is edited' do
      older_visit = create_visit(morning)
      create_visit(afternoon)

      described_class.apply_and_tariki_reached?(visit: older_visit)

      expect(house.reload.last_visit).to eq(afternoon)
    end

    it 'falls back to the next latest visit when the latest one is backdated' do
      create_visit(morning)
      latest_visit = create_visit(afternoon)
      backdated_at = Time.utc(2026, 10, 10, 15)

      latest_visit.update!(visited_at: backdated_at)
      described_class.apply_and_tariki_reached?(visit: latest_visit, previous_house: house,
                                                previous_visited_at: afternoon)

      expect(house.reload.last_visit).to eq(morning)
      expect(daily_last_visits(house)).to eq(
        [[Date.new(2026, 10, 10), backdated_at], [Date.new(2026, 10, 12), morning]]
      )
    end

    it 'reconciles both houses when a visit moves to another house' do
      create_visit(morning)
      moved_visit = create_visit(afternoon)

      moved_visit.update!(house: other_house)
      described_class.apply_and_tariki_reached?(visit: moved_visit, previous_house: house,
                                                previous_visited_at: afternoon)

      expect(house.reload.last_visit).to eq(morning)
      expect(other_house.reload.last_visit).to eq(afternoon)
      expect(daily_last_visits(house)).to eq([[Date.new(2026, 10, 12), morning]])
    end

    it 'clears the previous house when its only visit moves away' do
      moved_visit = create_visit(morning)

      moved_visit.update!(house: other_house)
      described_class.apply_and_tariki_reached?(visit: moved_visit, previous_house: house,
                                                previous_visited_at: morning)

      expect(house.reload).to have_attributes(last_visit: nil, status: nil)
      expect(daily_last_visits(house)).to be_empty
    end

    context 'when a visit completes the required streak of green days' do
      let(:snapshot) do
        {
          status: Constants::RiskColor::GREEN,
          counts: { infected_containers: 0, potential_containers: 0, non_infected_containers: 1 }
        }
      end

      before do
        allow(Services::RiskColorCalculator).to receive(:visit_snapshot).and_return(snapshot)
        allow(AppConfigParam).to receive(:tariki_required_green_visits).and_return(2)
      end

      it 'reports the transition only once' do
        reached = [morning, morning + 1.day, morning + 2.days].map do |visited_at|
          visit = Visit.create!(house:, team:, user_account:, questionnaire:, visited_at:)
          described_class.apply_and_tariki_reached?(visit:)
        end

        expect(reached).to eq([false, true, false])
        expect(house.reload).to have_attributes(status: Constants::RiskColor::GREEN, non_infected_containers: 1)
      end
    end
  end
end
