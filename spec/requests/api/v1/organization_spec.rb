# frozen_string_literal: true

RSpec.describe 'ApiDoc::V1::Organization::Api', :dox do
  include ApiDoc::V1::Organization::Api

  let(:base_path) { '/api/v1' }
  let(:organization1) { create(:organization, name: 'test', discarded_at: nil) }
  let(:organization2) { create(:organization, name: 'organization', discarded_at: nil) }

  let(:current_user) do
    create(:user_profile, :with_account)
  end
  let(:user_account) { current_user.user_account }

  let(:headers) { {} }
  let(:params) {  {} }
  let(:organization_id) { organization1.id }

  describe 'GET /index' do
    include ApiDoc::V1::Organization::Index

    before do
      organization1
      organization2
      get "#{base_path}/organizations", headers: headers, params: params
    end

    describe 'Success' do
      it 'renders organizations' do
        expect(response).to match_json_schema('organizations/index')
        expect(response).to match_resource_type('organization')
        expect(response).to be_ok
      end

      context 'when some filter is present' do
        let(:params) { { filter: { name: 'test' } } }

        it 'renders organizations with name filter' do
          total = response.parsed_body.dig('meta', 'total')
          expect(response).to match_resource_type('organization')
          p response.body
          expect(total).to eq 1
          expect(response).to be_ok
        end
      end
    end
  end

  describe 'GET /show' do
    include ApiDoc::V1::Organization::Show

    before do
      organization1
      get "#{base_path}/organizations/#{organization_id}", headers:, params:
    end

    describe 'Succcess' do
      it 'render organization details' do
        expect(response).to match_json_schema('organizations/show')
        expect(response).to match_resource_type('organization')
        expect(response).to be_truthy
      end
    end

    describe 'Failure' do
      let(:organization_id) { '0' }

      it 'returns not_found status' do
        expect(response).to be_not_found
        expect(response.body).to be_empty
      end
    end
  end

  describe 'POST /create' do
    include ApiDoc::V1::Organization::Create

    before do
      post "#{base_path}/organizations", params:, headers:, as: :json
    end

    describe 'Success' do
      let(:params) { attributes_for(:organization, name: 'Tariki') }

      it 'returns organization info' do
        expect(response).to match_json_schema('organizations/create')
        expect(response).to match_resource_type('organization')
        expect(response).to be_created
      end
    end

    describe 'Failure' do
      let(:params) { attributes_for(:organization, name: nil) }

      it 'returns organization info' do
        expect(response.code).to eq('422')
      end
    end
  end

  describe 'PUT /update' do
    include ApiDoc::V1::Organization::Update

    before do
      put "#{base_path}/organizations/#{organization_id}", params:, headers:, as: :json
    end

    describe 'Success' do
      let(:params) { attributes_for(:organization, name: 'Tariki 2') }

      it 'returns organization info' do
        expect(response).to match_json_schema('organizations/update')
        expect(response).to match_resource_type('organization')
        expect(response).to be_ok
      end
    end

    describe 'Failure' do
      let(:params) { attributes_for(:organization, name: nil) }

      it 'returns organization info' do
        expect(response.code).to eq('422')
      end
    end
  end

  describe 'DELETE /delete' do
    include ApiDoc::V1::Organization::Delete

    let(:params) { { organization_ids: [organization_id] } }

    before do
      delete "#{base_path}/organizations/", params:, headers:, as: :json
    end

    describe 'Success' do
      it 'returns 204' do
        expect(response.code).to eq('204')
      end
    end
  end
end
