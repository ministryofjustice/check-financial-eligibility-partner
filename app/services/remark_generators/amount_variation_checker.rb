module RemarkGenerators
  class AmountVariationChecker < BaseChecker
    def call
      populate_remarks unless unique_amounts || exempt_from_checking
    end

  private

    def exempt_from_checking
      Utilities::ChildcareExemptionDetector.call(record_type, disposable_income_subtotals)
    end

    def unique_amounts
      @collection.map(&:amount).uniq.size == 1
    end

    def populate_remarks
      my_remarks = @assessment.remarks
      my_remarks.add(record_type, :amount_variation, @collection.map(&:client_id))
      @assessment.update!(remarks: my_remarks)
    end
  end
end
