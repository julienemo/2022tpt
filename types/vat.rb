require_relative '../services/fake_vat_service'
require 'pry'

class Vat
  FULL_SCORE = 100

  DECREASING_RULES = { 
    unfavorable: { equal_and_above_threshold: 1, below_threshold: 3 },
    favorable: 1
  }.freeze

  def initialize(evaluation)
    @evaluation = evaluation
  end

  def update_with_api
    result = ::FakeVatService.perform(@evaluation.value).merge(score: FULL_SCORE)
    @evaluation.assign_fields(**result)
  end 

  def update_according_to_threshold
    return if @evaluation.state == 'unfavorable'

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

  def current_score
    @evaluation.score
  end
end
