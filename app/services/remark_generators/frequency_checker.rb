module RemarkGenerators
  class FrequencyChecker < BaseChecker
    def self.call(assessment, collection, disposable_income_subtotals = nil, date_attribute: :payment_date)
      new(assessment, collection, disposable_income_subtotals).call(date_attribute)
    end

    def call(date_attribute = :payment_date)
      @date_attribute = date_attribute
      populate_remarks if unknown_frequency? && !exempt_from_checking
    end

  private

    def exempt_from_checking
      Utilities::ChildcareExemptionDetector.call(record_type, disposable_income_subtotals)
    end

    def unknown_frequency?
      Utilities::PaymentPeriodAnalyser.new(dates).period_pattern == :unknown
    end

    def dates
      @collection.map { |rec| rec.send(@date_attribute) }
    end

    def populate_remarks
      my_remarks = @assessment.remarks
      my_remarks.add(record_type, :unknown_frequency, @collection.map(&:client_id))
      @assessment.update!(remarks: my_remarks)
    end
  end
end
