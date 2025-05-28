# frozen_string_literal: true

RSpec.shared_examples 'paginated collection errors' do
  context 'with empty params' do
    let(:page_params) { {} }
    let(:errors) { { page: ['is missing'] } }

    it_behaves_like 'has validation errors'
  end

  context 'with invalid params' do
    let(:page_params) { { page: 'wrong' } }
    let(:errors) { { page: ['must be a hash'] } }

    it_behaves_like 'has validation errors'
  end

  context 'when page is not valid' do
    let(:page_params) { { page: { number: 'wrong', size: 'wrong' } } }
    let(:errors) do
      {
        page: [
          [:number, ['must be an integer']],
          [:size, ['must be an integer']]
        ]
      }
    end

    it_behaves_like 'has validation errors'
  end

  context 'when page number is out of limits' do
    let(:page_params) { { page: { number: 10_000, size: 2 } } }
    let(:errors) { [{ field: :page, messages: ['is out of limits'], title: nil, meta: { type: :overflow } }] }

    it_behaves_like 'has validation errors'
  end

  context 'when page size is out of limits' do
    let(:page_params) { { page: { number: 1, size: 0 } } }
    let(:errors) { { page: [[:size, ['must be greater than or equal to 1']]] } }

    it_behaves_like 'has validation errors'
  end
end
