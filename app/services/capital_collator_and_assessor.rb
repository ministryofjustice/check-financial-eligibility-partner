class CapitalCollatorAndAssessor
  class << self
    def call(assessment)
      pensioner_capital_disregard = pensioner_capital_disregard(assessment)
      applicant_subtotals = collate_applicant_capital(assessment, pensioner_capital_disregard:)
      if assessment.partner.present?
        partner_subtotals = collate_partner_capital(assessment,
                                                    pensioner_capital_disregard: pensioner_capital_disregard - applicant_subtotals.pensioner_disregard_applied)
        combined_assessed_capital = applicant_subtotals.assessed_capital + partner_subtotals.assessed_capital
      else
        combined_assessed_capital = applicant_subtotals.assessed_capital
      end
      capital_contribution = Assessors::CapitalAssessor.call(assessment.capital_summary, combined_assessed_capital)
      CapitalSubtotals.new(
        applicant_capital_subtotals: applicant_subtotals,
        partner_capital_subtotals: partner_subtotals,
        capital_contribution:,
        combined_assessed_capital:,
      )
    end

  private

    def collate_applicant_capital(assessment, pensioner_capital_disregard:)
      Collators::CapitalCollator.call(
        submission_date: assessment.submission_date,
        capital_summary: assessment.capital_summary,
        maximum_subject_matter_of_dispute_disregard: maximum_subject_matter_of_dispute_disregard(assessment),
        pensioner_capital_disregard:,
        level_of_help: assessment.level_of_help,
      )
    end

    def collate_partner_capital(assessment, pensioner_capital_disregard:)
      Collators::CapitalCollator.call(
        submission_date: assessment.submission_date,
        capital_summary: assessment.partner_capital_summary,
        pensioner_capital_disregard:,
        # partner assets cannot be considered as a subject matter of dispute
        maximum_subject_matter_of_dispute_disregard: 0,
        level_of_help: assessment.level_of_help,
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
