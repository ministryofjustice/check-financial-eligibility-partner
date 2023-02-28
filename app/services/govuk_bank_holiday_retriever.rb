# frozen_string_literal: true

class GovukBankHolidayRetriever
  UnsuccessfulRetrievalError = Class.new(StandardError)

  def self.dates
    new.dates(CFEConstants::GOVUK_BANK_HOLIDAY_DEFAULT_GROUP)
  end

  def data
    raise_error unless response.is_a?(Net::HTTPOK)

    @data ||= JSON.parse(response.body)
  end

  def dates(group)
    data.dig(group, "events").pluck("date")
  end

private

  def response
    @response ||= Net::HTTP.get_response(uri)
  end

  def uri
    URI.parse(CFEConstants::GOVUK_BANK_HOLIDAY_API_URL)
  end

  def raise_error
    raise UnsuccessfulRetrievalError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
  end
end
