# frozen_string_literal: true

RSpec.shared_examples 'paginated with composite cursor errors' do |mixed_with_page_pagination: false|
  context 'with empty params' do
    let(:page_params) { {} }
    let(:errors) { { page: ['is missing'] } }

    include_examples 'has validation errors'
  end

  context 'with invalid params' do
    let(:page_params) { { page: 'wrong' } }
    let(:errors) { { page: ['must be a hash'] } }

    include_examples 'has validation errors'
  end

  context 'with after is not an integer' do
    let(:page_params) { { page: { after: 'invalid', size: 1, is_cursor: mixed_with_page_pagination } } }
    let(:errors) { { page: [[:after, ['must be an integer']]] } }

    include_examples 'has validation errors'
  end

  context 'with after is invalid' do
    let(:page_params) { { page: { after: -1, size: 1, is_cursor: mixed_with_page_pagination } } }
    let(:errors) { { page: [[:after, ['is out of scope']]] } }

    include_examples 'has validation errors'
  end

  context 'with before is not an integer' do
    let(:page_params) { { page: { before: 'invalid', size: 1, is_cursor: mixed_with_page_pagination } } }
    let(:errors) { { page: [[:before, ['must be an integer']]] } }

    include_examples 'has validation errors'
  end

  context 'with before is invalid' do
    let(:page_params) { { page: { before: -1, size: 1, is_cursor: mixed_with_page_pagination } } }
    let(:errors) { { page: [[:before, ['is out of scope']]] } }

    include_examples 'has validation errors'
  end

  context 'with size is not an integer' do
    let(:page_params) { { page: { size: 'invalid', is_cursor: mixed_with_page_pagination } } }
    let(:errors) { { page: [[:size, ['must be an integer']]] } }

    include_examples 'has validation errors'
  end

  context 'with size less than one' do
    let(:page_params) { { page: { size: 0, is_cursor: mixed_with_page_pagination } } }
    let(:errors) { { page: [[:size, ['must be greater than or equal to 1']]] } }

    include_examples 'has validation errors'
  end
end
