class CapitalCollatorAndAssessor
  class << self
    def call(assessment)
      data = collate_applicant_capital(assessment)
      assessment.capital_summary.update!(data.slice(:subject_matter_of_dispute_disregard, :pensioner_capital_disregard))
      if assessment.partner.present?
        partner_data = collate_partner_capital(assessment)
        assessment.capital_summary.update!(combined_assessed_capital: data[:assessed_capital] + partner_data[:assessed_capital])
      else
        assessment.capital_summary.update!(combined_assessed_capital: data[:assessed_capital])
      end
      contribution = Assessors::CapitalAssessor.call(assessment.capital_summary, assessment.capital_summary.combined_assessed_capital)
      CapitalSubtotals.new(
        applicant_capital_subtotals: PersonCapitalSubtotals.new(data),
        partner_capital_subtotals: (PersonCapitalSubtotals.new(partner_data) if assessment.partner.present?),
        capital_contribution: contribution,
      )
    end

  private

    def collate_applicant_capital(assessment)
      Collators::CapitalCollator.call(
        submission_date: assessment.submission_date,
        capital_summary: assessment.capital_summary,
        maximum_subject_matter_of_dispute_disregard: maximum_subject_matter_of_dispute_disregard(assessment),
        pensioner_capital_disregard: pensioner_capital_disregard(assessment),
      )
    end

    def collate_partner_capital(assessment)
      Collators::CapitalCollator.call(
        submission_date: assessment.submission_date,
        capital_summary: assessment.partner_capital_summary,
        pensioner_capital_disregard: 0,
        maximum_subject_matter_of_dispute_disregard: 0,
      )
    end

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
