require_relative '../evaluation'
require_relative '../types/siren'
require_relative '../types/vat'

RSpec.describe Evaluation do
  describe '#update!' do
    let(:double_siren) { instance_double(::Siren) }
    let(:double_vat) { instance_double(::Vat) }

    before do
      allow(::Siren).to receive(:new).and_return(double_siren)
      allow(double_siren).to receive(:update_with_api)
      allow(double_siren).to receive(:update_according_to_threshold)
      allow(double_siren).to receive(:update_favorable)

      allow(::Vat).to receive(:new).and_return(double_vat)
      allow(double_vat).to receive(:update_with_api)
      allow(double_vat).to receive(:update_according_to_threshold)
      allow(double_vat).to receive(:update_favorable)
    end

    context 'when <state> unfavorable' do
      let(:siren_evaluation) do
        ::Evaluation.new(type: 'SIREN', value: '320878499', score: 3, state: 'unfavorable', reason: 'company_opened')
      end
      let(:vat_evaluation) do
        ::Evaluation.new(type: 'VAT', value: 'GB727255821', score: 3, state: 'unfavorable', reason: 'company_opened')
      end
      it 'changes nothing' do
        expect { siren_evaluation.update! }.not_to change { siren_evaluation.score }
        expect { siren_evaluation.update! }.not_to change { siren_evaluation.reason }
        expect { siren_evaluation.update! }.not_to change { siren_evaluation.state }
        expect { vat_evaluation.update! }.not_to change { vat_evaluation.score }
        expect { vat_evaluation.update! }.not_to change { vat_evaluation.reason }
        expect { vat_evaluation.update! }.not_to change { vat_evaluation.state }
      end
    end

    context 'when update_with_api should trigger' do
      shared_examples 'triggers update_with_api' do
        it 'triggers triggers update_with_api' do
          siren_evaluation.update!
          vat_evaluation.update!
  
          expect(double_siren).to have_received(:update_with_api)
          expect(double_vat).to have_received(:update_with_api)
        end
      end

      context 'when <state> unconfirmed and <reason> ongoing_database_update' do
        let(:siren_evaluation) do
          ::Evaluation.new(type: 'SIREN', value: '320878499', score: 3, state: 'unconfirmed', reason: 'ongoing_database_update')
        end
        let(:vat_evaluation) do
          ::Evaluation.new(type: 'VAT', value: 'GB727255821', score: 3, state: 'unconfirmed', reason: 'ongoing_database_update')
        end

        include_examples 'triggers update_with_api'
      end
  
      context 'when <score> 0' do
        let(:siren_evaluation) do
          ::Evaluation.new(type: 'SIREN', value: '320878499', score: 0, state: 'favorable', reason: 'company_opened')
        end
        let(:vat_evaluation) do
          ::Evaluation.new(type: 'VAT', value: 'GB727255821', score: 0, state: 'favorable', reason: 'company_opened')
        end
        
        include_examples 'triggers update_with_api'
      end
    end

    context 'when <state> unconfirmed AND <reason> unable_to_reach_api' do
      let(:siren_evaluation) do
        ::Evaluation.new(type: 'SIREN', value: '320878499', score: 3, state: 'unconfirmed', reason: 'unable_to_reach_api')
      end
      let(:vat_evaluation) do
        ::Evaluation.new(type: 'VAT', value: 'GB727255821', score: 3, state: 'unconfirmed', reason: 'unable_to_reach_api')
      end

      it 'triggers triggers update_according_to_threshold' do
        siren_evaluation.update!
        vat_evaluation.update!

        expect(double_siren).to have_received(:update_according_to_threshold)
        expect(double_vat).to have_received(:update_according_to_threshold)
      end
    end

    context 'when <state> favorable' do
      let(:siren_evaluation) do
        ::Evaluation.new(type: 'SIREN', value: '320878499', score: 3, state: 'favorable', reason: 'company_closeed')
      end
      let(:vat_evaluation) do
        ::Evaluation.new(type: 'VAT', value: 'GB727255821', score: 3, state: 'favorable', reason: 'company_opened')
      end

      it 'triggers update_favorable' do
        siren_evaluation.update!
        vat_evaluation.update!

        expect(double_siren).to have_received(:update_favorable)
        expect(double_vat).to have_received(:update_favorable)
      end
    end
  end

  describe '#assign_fields' do
    let(:evaluation) { ::Evaluation.new(score: 3, type: 'type', value: 'value', state: 'state', reason: 'reason') }

    context 'when <score> is negative' do
      it 'limits score to 0' do
        expect(evaluation.assign_fields(score: -5).score).to eq(0)
      end
    end

    context 'when <score>, <reason> AND <state> are all provided' do
      it 'assigns all 3 attributes' do
        evaluation.assign_fields(score: 5, reason: 'good', state: 'ok')
        expect(evaluation.score).to eq(5)
        expect(evaluation.reason).to eq('good')
        expect(evaluation.state).to eq('ok')
      end
    end

    context 'when any attribute is not provided' do
      it 'does not update the attribute' do
        expect(evaluation.assign_fields(score: 30, reason: 'ahh').state).to eq('state')
        expect(evaluation.assign_fields(score: 30, state: 'what?').reason).to eq('ahh')
        expect(evaluation.assign_fields(state: 'oups', reason: 'ahh').score).to eq(30)
      end
    end
  end
end
