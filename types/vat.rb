require_relative './type_base'
require_relative '../evaluation'
require_relative '../services/fake_vat_service'

class Vat < TypeBase
  DECREASING_RULES = { equal_and_above_threshold: 1, below_threshold: 3 }.freeze

  def update_with_api
    result = FakeVatService.perform(@evaluation.value).merge(score: Evaluation::FULL_SCORE)
    @evaluation.assign_fields(**result)
  end

  def update_according_to_threshold
    if current_score >= Evaluation::SCORE_THRESHOLD
      @evaluation.assign_fields(score: current_score - DECREASING_RULES[:equal_and_above_threshold])
    else
      @evaluation.assign_fields(score: current_score - DECREASING_RULES[:below_threshold])
    end
  end
end
