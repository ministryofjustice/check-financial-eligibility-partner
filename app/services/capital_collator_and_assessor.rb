class CapitalCollatorAndAssessor
  class << self
    def call(assessment)
      data = Collators::CapitalCollator.call(
        submission_date: assessment.submission_date,
        capital_summary: assessment.capital_summary,
        maximum_subject_matter_of_dispute_disregard: maximum_subject_matter_of_dispute_disregard(assessment),
        pensioner_capital_disregard: pensioner_capital_disregard(assessment),
      )
      assessment.capital_summary.update!(data)
      vehicles = assessment.capital_summary.vehicles.map do |v|
        Assessors::VehicleAssessor.call(value: v.value,
                                        loan_amount_outstanding: v.loan_amount_outstanding,
                                        submission_date: assessment.submission_date,
                                        in_regular_use: v.in_regular_use,
                                        date_of_purchase: v.date_of_purchase)
      end
      if assessment.partner.present?
        partner_data = Collators::CapitalCollator.call(
          submission_date: assessment.submission_date,
          capital_summary: assessment.partner_capital_summary,
          pensioner_capital_disregard: 0,
          maximum_subject_matter_of_dispute_disregard: 0,
        )
        assessment.partner_capital_summary.update!(partner_data)
        partner_vehicles = assessment.partner_capital_summary.vehicles.map do |v|
          Assessors::VehicleAssessor.call(value: v.value,
                                          loan_amount_outstanding: v.loan_amount_outstanding,
                                          submission_date: assessment.submission_date,
                                          in_regular_use: v.in_regular_use,
                                          date_of_purchase: v.date_of_purchase)
        end

        assessment.capital_summary.update!(combined_assessed_capital: assessment.capital_summary.assessed_capital +
                                                                        assessment.partner_capital_summary.assessed_capital)
        Assessors::CapitalAssessor.call(assessment.capital_summary, assessment.capital_summary.combined_assessed_capital)
        AssessmentResult.new vehicles: vehicles, partner_vehicles: partner_vehicles
      else
        assessment.capital_summary.update!(combined_assessed_capital: assessment.capital_summary.assessed_capital)
        Assessors::CapitalAssessor.call(assessment.capital_summary, assessment.capital_summary.combined_assessed_capital)
        AssessmentResult.new vehicles: vehicles
      end
    end

  private

    def total_disposable_income(assessment)
      if assessment.partner.present?
        assessment.disposable_income_summary.total_disposable_income +
          assessment.partner_disposable_income_summary.total_disposable_income
      else
        assessment.disposable_income_summary.total_disposable_income
      end
    end

    def pensioner_capital_disregard(assessment)
      applicant_value = Calculators::PensionerCapitalDisregardCalculator.new(
        submission_date: assessment.submission_date,
        receives_qualifying_benefit: assessment.applicant.receives_qualifying_benefit,
        total_disposable_income: total_disposable_income(assessment),
        person: assessment.applicant,
      ).value
      if assessment.partner.present?
        partner_value = Calculators::PensionerCapitalDisregardCalculator.new(
          submission_date: assessment.submission_date,
          receives_qualifying_benefit: assessment.applicant.receives_qualifying_benefit,
          total_disposable_income: total_disposable_income(assessment),
          person: assessment.partner,
        ).value
      end
      [applicant_value, partner_value].compact.max
    end

    def maximum_subject_matter_of_dispute_disregard(assessment)
      Threshold.value_for(:subject_matter_of_dispute_disregard, at: assessment.submission_date)
    end
  end
end
