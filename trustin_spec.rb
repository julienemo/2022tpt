# frozen_string_literal: true
require_relative './evaluation'
require_relative './trustin'
require_relative './services/fake_vat_service'

RSpec.describe TrustIn do
  describe '.update_score_for_all' do
    context 'when evaluation type is "SIREN"' do
      subject { described_class.update_score_for_all(evaluations) }

      context "with a <score> greater or equal to 50 AND the <state> is unconfirmed and the <reason> is 'unable_to_reach_api'" do
        let(:evaluations) { [Evaluation.new(type: "SIREN", value: "123456789", score: 79, state: "unconfirmed", reason: "unable_to_reach_api")] }

        it "decreases the <score> of 5" do
          subject
          expect(evaluations.first.score).to eq(74)
        end
      end

      context "when the <state> is unconfirmed and the <reason> is 'unable_to_reach_api'" do
        let(:evaluations) { [Evaluation.new(type: "SIREN", value: "123456789", score: 37, state: "unconfirmed", reason: "unable_to_reach_api")] }

        it "decreases the <score> of 1" do
          subject
          expect(evaluations.first.score).to eq(36)
        end
      end

      context "when the <state> is favorable" do
        let(:evaluations) { [Evaluation.new(type: "SIREN", value: "123456789", score: 28, state: "favorable", reason: "company_opened")] }

        it "decreases the <score> of 1" do
          subject
          expect(evaluations.first.score).to eq(27)
        end
      end

      context "when the <state> is 'unconfirmed' AND the <reason> is 'ongoing_database_update'" do
        let(:evaluations) { [Evaluation.new(type: "SIREN", value: "832940670", score: 42, state: "unconfirmed", reason: "ongoing_database_update")] }

        before { allow(OpenDataService).to receive(:get_company_state).and_return('Actif')}

        it "assigns a <state> and a <reason> to the evaluation based on the API response and a <score> to 100" do
          subject
          expect(evaluations.first.state).to eq("favorable")
          expect(evaluations.first.reason).to eq("company_opened")
          expect(evaluations.first.score).to eq(100)
        end
      end

      context "with a <score> equal to 0" do
        let(:evaluations) { [Evaluation.new(type: "SIREN", value: "320878499", score: 0, state: "favorable", reason: "company_opened")] }

        before { allow(OpenDataService).to receive(:get_company_state).and_return('Inactif')}

        it "assigns a <state> and a <reason> to the evaluation based on the API response and a <score> to 100" do
          subject
          expect(evaluations.first.state).to eq("unfavorable")
          expect(evaluations.first.reason).to eq("company_closed")
          expect(evaluations.first.score).to eq(100)
        end
      end

      context "with a <state> 'unfavorable'" do
        let(:evaluations) { [Evaluation.new(type: "SIREN", value: "123456789", score: 52, state: "unfavorable", reason: "company_closed")] }

        it "does not decrease its <score>" do
          expect { subject }.not_to change { evaluations.first.score }
        end
      end

      context "with a <state>'unfavorable' AND a <score> equal to 0" do
        let(:evaluations) { [Evaluation.new(type: "SIREN", value: "123456789", score: 0, state: "unfavorable", reason: "company_closed")] }

        it "does not call the API" do
          subject
          expect(Net::HTTP).not_to receive(:get)
        end
      end
    end

    context 'when evaluation type is "VAT"' do
      context "with a <score> greater or equal to 50 AND the <state> is unconfirmed and the <reason> is 'unable_to_reach_api'" do
        let(:evaluations) { [Evaluation.new(type: 'VAT', value: '123456789', score: 79, state: 'unconfirmed', reason: 'unable_to_reach_api')] }

        it 'decreases the <score> of 1' do
          described_class.update_score_for_all(evaluations)
          expect(evaluations.first.score).to eq(78)
        end
      end

      context 'when the <state> is unconfirmed and the <reason> is unable_to_reach_api' do
        let(:evaluations) { [Evaluation.new(type: 'VAT', value: '123456789', score: 37, state: 'unconfirmed', reason: 'unable_to_reach_api')] }

        it 'decreases the <score> of 3' do
          described_class.update_score_for_all(evaluations)
          expect(evaluations.first.score).to eq(34)
        end
      end

      context 'when the <state> is favorable' do
        let(:evaluations) { [Evaluation.new(type: 'VAT', value: '123456789', score: 28, state: 'favorable', reason: 'company_opened')] }

        it 'decreases the <score> of 1' do
          described_class.update_score_for_all(evaluations)
          expect(evaluations.first.score).to eq(27)
        end
      end

      context 'when the <state> is unconfirmed AND the <reason> is ongoing_database_update' do
        let(:evaluations) { [Evaluation.new(type: 'VAT', value: '832940670', score: 42, state: 'unconfirmed', reason: 'ongoing_database_update')] }
        
        before { allow(FakeVatService).to receive(:perform).and_return({ state: 'favorable', reason: 'company_opened' }) }

        it 'assigns a <state> and a <reason> to the evaluation based on the API response and a <score> to 100' do
          described_class.update_score_for_all(evaluations)
          expect(evaluations.first.state).to eq('favorable')
          expect(evaluations.first.reason).to eq('company_opened')
          expect(evaluations.first.score).to eq(100)
        end
      end

      context 'with a <score> equal to 0' do
        let(:evaluations) { [Evaluation.new(type: 'VAT', value: '320878499', score: 0, state: 'favorable', reason: 'company_opened')] }

        before { allow(FakeVatService).to receive(:perform).and_return({ state: 'unfavorable', reason: 'company_closed' }) }

        it 'assigns a <state> and a <reason> to the evaluation based on the API response and a <score> to 100' do
          described_class.update_score_for_all(evaluations)
          expect(evaluations.first.state).to eq('unfavorable')
          expect(evaluations.first.reason).to eq('company_closed')
          expect(evaluations.first.score).to eq(100)
        end
      end

      context 'with a <state> unfavorable' do
        let(:evaluations) { [Evaluation.new(type: 'VAT', value: 'LU26375245', score: 52, state: 'unfavorable', reason: 'company_closed')] }

        it 'does not decrease its <score>' do
          expect { subject }.not_to change { evaluations.first.score }
        end
      end

      context 'with a <state> unfavorable AND a <score> equal to 0' do
        let(:evaluations) { [Evaluation.new(type: 'VAT', value: 'IE6388047V', score: 0, state: 'unfavorable', reason: 'anything')] }

        before { allow(FakeVatService).to receive(:perform) }

        it 'does not call FakeVatService.perform' do
          described_class.update_score_for_all(evaluations)
          expect(FakeVatService).not_to have_received(:perform)
        end
      end
    end
  end
end
