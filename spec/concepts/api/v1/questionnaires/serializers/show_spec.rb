# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::V1::Questionnaires::Serializers::Show do
  subject(:serialized_questionnaire) { described_class.new(questionnaire).serializable_hash }

  let!(:questionnaire_record) do
    Questionnaire.create!(
      name: 'Current questionnaire',
      current_form: true,
      initial_question: 1,
      final_question: 1
    )
  end
  let!(:question) do
    questionnaire_record.questions.create!(
      question_text_en: 'Question',
      type_field: 'list',
      next: 1
    )
  end
  let!(:option) do
    question.options.create!(
      name_en: 'Risk option',
      position: 1,
      status_color: Constants::RiskColor::GREEN
    )
  end
  let(:questionnaire) do
    OpenStruct.new(questionnaire_record.attributes).tap do |record|
      record.questions = [question]
      record.language = 'en'
    end
  end

  it 'serializes risk colors using the uppercase mobile contract' do
    status_color = serialized_questionnaire.dig(:data, :attributes, :questions, 0, :options, 0, :statusColor)

    expect(status_color).to eq('GREEN')
    expect(option.reload.status_color).to eq('green')
  end
end
