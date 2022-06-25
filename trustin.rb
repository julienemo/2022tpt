require_relative './evaluation'

class TrustIn
  class << self
    def update_score_for_all(evaluations)
      evaluations.map(&:update!)
    end  
  end
end
