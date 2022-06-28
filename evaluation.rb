require_relative './helper'
require_relative './types/siren'
require_relative './types/vat'

class Evaluation
  TYPES = { siren: 'SIREN', vat: 'VAT' }.freeze
  SCORE_THRESHOLD = 50
  FULL_SCORE = 100

  attr_reader :type, :value, :score, :state, :reason

  def initialize(type:, value:, score:, state:, reason:)
    @type = type
    @value = value
    @score = score
    @state = state
    @reason = reason
  end

  def update!
    return if @state == 'unfavorable'

    raise "Unknow evaluation type #{@type}" unless TYPES.values.include?(@type)

    if should_update_with_api?
      Helper.constantize(@type).new(self).update_with_api
    elsif should_upate_according_to_threshold?
      Helper.constantize(@type).new(self).update_according_to_threshold
    else
      Helper.constantize(@type).new(self).update_favorable
    end
  end

  def assign_fields(state: nil, reason: nil, score: nil)
    @state = state || @state
    @reason = reason || @reason
    @score = score || @score
    @score = 0 if @score.negative?

    self
  end

  private

  def should_update_with_api?
    return false if @state == 'unfavorable'

    unconfirmed_for_ongoing_update = @state == 'unconfirmed' && @reason == 'ongoing_database_update'
    unconfirmed_for_ongoing_update || @score.zero?
  end

  def should_upate_according_to_threshold?
    @state == 'unconfirmed' && @reason == 'unable_to_reach_api'
  end
end
