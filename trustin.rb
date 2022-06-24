require_relative './evaluation'
require_relative './types/siren'

class TrustIn
  def initialize(evaluations)
    @evaluations = evaluations
  end

  def update_score
    @evaluations.each do |evaluation|
      case evaluation.type
      when ::Evaluation::TYPES[:siren]
        ::Siren.new(evaluation).update
      end
    end
  end
end
