require 'pry'
class Evaluation
  TYPES = { siren: 'SIREN', vat: 'VAT' }.freeze
  SCORE_THRESHOLD = 50

  attr_reader :type, :value, :score, :state, :reason

  def initialize(type:, value:, score:, state:, reason:)
    @type = type
    @value = value
    @score = score
    @state = state
    @reason = reason
  end

  def print_fields
    "#{@type}, #{@value}, #{@score}, #{@state}, #{@reason}"
  end

  def assign_fields(state: nil, reason: nil, score: nil)
    @state = state || @state
    @reason = reason || @reason
    @score = score || @score
  end

  def should_be_evalutated?
    return false if @state == 'unfavorable'

    unconfirmed_for_ongoing_update = @state == 'unconfirmed' && reason == 'ongoing_database_update'
    unconfirmed_for_ongoing_update || @score.zero?
  end
end
