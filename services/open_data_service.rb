require 'json'
require 'net/http'

class OpenDataService
  BASE_URL = 'https://public.opendatasoft.com/api/records/1.0/search/?dataset=sirene_v3'.freeze
  DEFAULT_PARAMS = '&sort=datederniertraitementetablissement&refine.etablissementsiege=oui'.freeze

  class << self 
    def get_company_state(siren_number)
      # I don't like the name evalutaion_value, because I don't understand its meaning
      response = Net::HTTP.get(query_uri(siren_number))
      parsed_response = JSON.parse(response)
      parsed_response['records'].first['fields']['etatadministratifetablissement']
    rescue
      raise 'Error getting OpenDataSoft response'
    end

    private

    def query_uri(siren_number)
      URI("#{BASE_URL}&q=#{siren_number}#{DEFAULT_PARAMS}")
    end
  end
end
