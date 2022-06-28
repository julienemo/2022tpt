require_relative './evaluation'

class TrustIn
  class << self
    def update_score_for_all(evaluations)
      evaluations.each do |evaluation|
        evaluation.update!
      rescue RuntimeError => e
        puts "#{e} for evalutaion value #{e.value}"
      end
    end
  end
end
