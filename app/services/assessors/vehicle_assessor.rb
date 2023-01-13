module Assessors
  class VehicleAssessor
    class << self
      def call(value:, loan_amount_outstanding:, submission_date:, in_regular_use:, date_of_purchase:)
        if in_regular_use
          assess_vehicle_in_regular_use(value:, loan_amount_outstanding:, submission_date:, date_of_purchase:)
        else
          assess_vehicle_not_in_regular_use(value:)
        end
      end

    private

      def assess_vehicle_not_in_regular_use(value:)
        { included_in_assessment: true, value: }
      end

      def assess_vehicle_in_regular_use(value:, loan_amount_outstanding:, submission_date:, date_of_purchase:)
        net_value = value - loan_amount_outstanding
        if vehicle_age_in_months(date_of_purchase:, submission_date:) >= vehicle_out_of_scope_age(submission_date:) || net_value <= vehicle_disregard(submission_date:)
          { included_in_assessment: false, value: 0 }
        else
          { included_in_assessment: true, value: net_value - vehicle_disregard(submission_date:) }
        end
      end

      def vehicle_age_in_months(date_of_purchase:, submission_date:)
        Calculators::VehicleAgeCalculator.new(date_of_purchase, submission_date).in_months
      end

      def vehicle_out_of_scope_age(submission_date:)
        Threshold.value_for(:vehicle_out_of_scope_months, at: submission_date)
      end

      def vehicle_disregard(submission_date:)
        Threshold.value_for(:vehicle_disregard, at: submission_date)
      end
    end
  end
end
