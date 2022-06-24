require "json"
require "net/http"
require_relative './open_data_service'

class TrustIn
  def initialize(evaluations)
    @evaluations = evaluations
  end

  def update_score()
    @evaluations.each do |evaluation|
      if evaluation.type == "SIREN"
        if evaluation.score > 0 && evaluation.state == "unconfirmed" && evaluation.reason == "ongoing_database_update"
          company_state = ::OpenDataService::get_company_state(evaluation.value)
          if company_state == "Actif"
            evaluation.assign_fields(state: "favorable", reason: "company_opened", score: 100)
          else
            evaluation.assign_fields(state: "unfavorable", reason:"company_closed", score: 100)
          end
        elsif evaluation.score >= 50
          if evaluation.state == "unconfirmed" && evaluation.reason == "unable_to_reach_api"
            evaluation.assign_fields(state: nil, reason: nil, score: evaluation.score - 5)
          elsif evaluation.state == "favorable"
            evaluation.assign_fields(state: nil, reason: nil, score: evaluation.score - 1)
          end
        elsif evaluation.score <= 50 && evaluation.score > 0
          if evaluation.state == "unconfirmed" && evaluation.reason == "unable_to_reach_api" || evaluation.state == "favorable"
            evaluation.assign_fields(state: nil, reason: nil, score: evaluation.score - 1)
          end
        else
          if evaluation.state == "favorable" || evaluation.state == "unconfirmed"
            company_state = ::OpenDataService::get_company_state(evaluation.value)
            if company_state == "Actif"
              evaluation.assign_fields(state: "favorable", reason:"company_opened", score: 100)
            else
              evaluation.assign_fields(state: "unfavorable", reason:"company_closed", score: 100)
            end
          end
        end
      end
    end
  end
end
