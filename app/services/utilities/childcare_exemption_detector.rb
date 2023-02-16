module Utilities
  class ChildcareExemptionDetector
    class << self
      def call(record_type, disposable_income_subtotals)
        return false unless record_type == :outgoings_childcare

        # If we have childcare records, but the 'bank' total value of
        # childcare is zero, that means childcare has evidently been disallowed
        # That means this child care record is exempt from checking.
        disposable_income_subtotals.categorised_outgoings(:bank, :child_care).zero?
      end
    end
  end
end
