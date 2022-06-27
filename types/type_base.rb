class TypeBase
  FAVORABLE_DECREASING_POINT = 1

  def initialize(evaluation)
    @evaluation = evaluation
  end

  def update_with_api
    @evaluation.type.constantize.new(@evaluation).update_with_api
  end

  def update_according_to_threshold
    @evaluation.type.constantize.new(@evaluation).update_according_to_threshold
  end

  def update_favorable
    @evaluation.assign_fields(score: current_score - FAVORABLE_DECREASING_POINT)
  end

  private

  def current_score
    @evaluation.score
  end
end
