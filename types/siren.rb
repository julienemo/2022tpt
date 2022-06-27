require_relative './type_base'
require_relative '../evaluation'
require_relative '../services/open_data_service'

class Siren < TypeBase
  DECREASING_RULES = { equal_and_above_threshold: 5, below_threshold: 1 }.freeze

  def update_with_api
    company_state = ::OpenDataService.get_company_state(@evaluation.value)
    return assign_company_active_result if company_state == 'Actif'

    assign_company_closed_result
  end

  def update_according_to_threshold
    if current_score >= ::Evaluation::SCORE_THRESHOLD
      @evaluation.assign_fields(score: current_score - DECREASING_RULES[:equal_and_above_threshold])
    else
      @evaluation.assign_fields(score: current_score - DECREASING_RULES[:below_threshold])
    end
  end

  private

  def assign_company_active_result
    @evaluation.assign_fields(state: 'favorable', reason: 'company_opened', score: Evaluation::FULL_SCORE)
  end

  def assign_company_closed_result
    @evaluation.assign_fields(state: 'unfavorable', reason: 'company_closed', score: Evaluation::FULL_SCORE)
  end
end
