class FakeVatService
  class << self
    def perform(_vat_number)
      [
        { state: 'favorable', reason: 'company_opened' },
        { state: 'unfavorable', reason: 'company_closed' },
        { state: 'unconfirmed', reason: 'unable_to_reach_api' },
        { state: 'unconfirmed', reason: 'ongoing_database_update' }
      ].sample
    end
  end
end
