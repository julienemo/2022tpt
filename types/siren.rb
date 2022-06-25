require_relative '../services/open_data_service'

class Siren
  FULL_SCORE = 100
  DECREASING_RULES = {
    unfavorable: { equal_and_above_threshold: 5, below_threshold: 1 },
    favorable: 1
  }.freeze

  def initialize(evaluation)
    @evaluation = evaluation
  end

  def update_with_api
    company_state = ::OpenDataService.get_company_state(@evaluation.value)
    return assign_company_active_result if company_state == 'Actif'

    assign_company_closed_result
  end

  def update_according_to_threshold
    decreasing_scores = DECREASING_RULES[:unfavorable]

    if current_score >= ::Evaluation::SCORE_THRESHOLD
      @evaluation.assign_fields(score: current_score - decreasing_scores[:equal_and_above_threshold])
    else
      @evaluation.assign_fields(score: current_score - decreasing_scores[:below_threshold])
    end
  end

  def update_favorable
    @evaluation.assign_fields(score: current_score - DECREASING_RULES[:favorable])
  end

  private

  def assign_company_active_result
    @evaluation.assign_fields(state: 'favorable', reason: 'company_opened', score: FULL_SCORE)
  end

  def assign_company_closed_result
    @evaluation.assign_fields(state: 'unfavorable', reason: 'company_closed', score: FULL_SCORE)
  end

  def current_score
    @evaluation.score
  end
end
