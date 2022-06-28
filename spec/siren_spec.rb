require_relative '../types/siren'
require_relative '../evaluation'
require_relative '../services/open_data_service'

RSpec.describe Siren do
  let(:siren) { Siren.new(evaluation) }

  before { allow(evaluation).to receive(:assign_fields) }

  describe '#update_with_api' do
    subject(:update_evaluation_with_api) { described_class.new(evaluation).update_with_api }

    let(:evaluation) { Evaluation.new(score: 3, type: 'SIREN', value: 'value', state: 'state', reason: 'reason') }

    context 'when company is actif' do
      before { allow(OpenDataService).to receive(:get_company_state).and_return('Actif') }

      it 'assigns evaluation with <state> favorable, <reason> company_opened <score> 100' do
        update_evaluation_with_api
        expect(evaluation).to have_received(:assign_fields).with(score: 100, reason: 'company_opened', state: 'favorable')
      end
    end

    context 'when company not actif' do
      before { allow(OpenDataService).to receive(:get_company_state).and_return('Else') }

      it 'assigns evaluation with <state> unfavorable, <reason> company_closed <score> 100' do
        update_evaluation_with_api
        expect(evaluation).to have_received(:assign_fields).with(score: 100, reason: 'company_closed', state: 'unfavorable')
      end
    end
  end

  describe '#update_according_to_threshold' do
    subject(:update_evaluation_according_to_threshold) { described_class.new(evaluation).update_according_to_threshold }

    context 'when <score> above 50' do
      let(:evaluation) { Evaluation.new(score: 55, type: 'SIREN', value: 'value', state: 'unconfirmed', reason: 'unable_to_reach_api') }

      it 'assigns evaluation with <score> less 5' do
        update_evaluation_according_to_threshold
        expect(evaluation).to have_received(:assign_fields).with(score: 50)
      end
    end

    context 'when <score> below 50' do
      let(:evaluation) { Evaluation.new(score: 5, type: 'SIREN', value: 'value', state: 'unconfirmed', reason: 'unable_to_reach_api') }

      it 'assigns evaluation with <score> less 1' do
        update_evaluation_according_to_threshold
        expect(evaluation).to have_received(:assign_fields).with(score: 4)
      end
    end
  end

  describe '#update_favorable' do
    subject(:update_evaluation_favorable) { described_class.new(evaluation).update_favorable }

    let(:evaluation) { Evaluation.new(score: 5, type: 'SIREN', value: 'value', state: 'favorable', reason: 'unable_to_reach_api') }

    it 'assigns evaluation with <score> less 1' do
      update_evaluation_favorable
      expect(evaluation).to have_received(:assign_fields).with(score: 4)
    end
  end
end
