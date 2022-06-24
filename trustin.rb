require_relative './evaluation'
require_relative './types/siren'

class TrustIn
  class << self
    def update_score_for_all(evaluations)
      evaluations.each do |evaluation|
        case evaluation.type
        when ::Evaluation::TYPES[:siren]
          ::Siren.new(evaluation).update
        end
      end
    end  
  end
end
