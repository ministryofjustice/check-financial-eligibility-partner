module Workflows
  class NonPassportedWorkflow
    DisposableIncomeData = Data.define(:applicant_disposable_income_subtotals,
                                       :partner_disposable_income_subtotals,
                                       :combined_monthly_outgoings,
                                       :combined_monthly_disposable_income)

    class << self
      def call(assessment)
        new(assessment).call
      end
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      return SelfEmployedWorkflow.call(assessment) if assessment.applicant.self_employed?

      gross_income_subtotals = collate_and_assess_gross_income
      return CalculationOutput.new(gross_income_subtotals:) if assessment.gross_income_summary.ineligible?

      disposable_income_subtotals = collate_and_assess_disposable_income(gross_income_subtotals)
      return CalculationOutput.new(gross_income_subtotals:, disposable_income_subtotals:) if assessment.disposable_income_summary.ineligible?

      capital_subtotals = collate_and_assess_capital(disposable_income_subtotals.combined_monthly_disposable_income)
      CalculationOutput.new(capital_subtotals:, gross_income_subtotals:, disposable_income_subtotals:)
    end

  private

    attr_reader :assessment

    def collate_and_assess_gross_income
      applicant_gross_income_subtotals = Collators::GrossIncomeCollator.call(assessment:,
                                                                             submission_date: assessment.submission_date,
                                                                             employments: assessment.employments,
                                                                             gross_income_summary: assessment.gross_income_summary)
      if assessment.partner.present?
        partner_gross_income_subtotals = Collators::GrossIncomeCollator.call(assessment:,
                                                                             submission_date: assessment.submission_date,
                                                                             employments: assessment.partner_employments,
                                                                             gross_income_summary: assessment.partner_gross_income_summary)
        combined_monthly_gross_income = applicant_gross_income_subtotals.total_gross_income +
          partner_gross_income_subtotals.total_gross_income
      else
        combined_monthly_gross_income = applicant_gross_income_subtotals.total_gross_income
      end

      Assessors::GrossIncomeAssessor.call(
        eligibilities: assessment.gross_income_summary.eligibilities,
        total_gross_income: combined_monthly_gross_income,
      )

      GrossIncomeSubtotals.new(
        applicant_gross_income_subtotals:,
        partner_gross_income_subtotals:,
        combined_monthly_gross_income:,
      )
    end

    def collate_and_assess_disposable_income(gross_income_subtotals)
      subtotals = if assessment.partner.present?
                    disposable_income_subtotals_with_partner(gross_income_subtotals)
                  else
                    disposable_income_subtotals_without_partner(gross_income_subtotals)
                  end

      DisposableIncomeSubtotals.new applicant_disposable_income_subtotals: subtotals.applicant_disposable_income_subtotals,
                                    partner_disposable_income_subtotals: subtotals.partner_disposable_income_subtotals,
                                    combined_monthly_outgoings: subtotals.combined_monthly_outgoings,
                                    combined_monthly_disposable_income: subtotals.combined_monthly_disposable_income,
                                    monthly_income_contribution: Assessors::DisposableIncomeAssessor.call(disposable_income_summary: assessment.disposable_income_summary,
                                                                                                          total_disposable_income: subtotals.combined_monthly_disposable_income)
    end

    def disposable_income_subtotals_with_partner(gross_income_subtotals)
      applicant = PersonWrapper.new person: assessment.applicant, is_single: false,
                                    dependants: assessment.dependants, gross_income_summary: assessment.gross_income_summary
      partner = PersonWrapper.new person: assessment.partner, is_single: false,
                                  dependants: assessment.partner_dependants, gross_income_summary: assessment.partner_gross_income_summary
      eligible_for_childcare = calculate_childcare_eligibility(applicant, partner)
      applicant_disposable_income_subtotals = collate_outgoings(applicant,
                                                                assessment.disposable_income_summary,
                                                                gross_income_subtotals.applicant_gross_income_subtotals,
                                                                eligible_for_childcare:,
                                                                allow_negative_net: true,
                                                                partner_allowance:)
      partner_disposable_income_subtotals = collate_outgoings(partner,
                                                              assessment.partner_disposable_income_summary,
                                                              gross_income_subtotals.partner_gross_income_subtotals,
                                                              eligible_for_childcare:,
                                                              allow_negative_net: true,
                                                              partner_allowance: 0)

      DisposableIncomeData.new(
        applicant_disposable_income_subtotals:,
        partner_disposable_income_subtotals:,
        combined_monthly_outgoings: applicant_disposable_income_subtotals.total_monthly_outgoings + partner_disposable_income_subtotals.total_monthly_outgoings,
        combined_monthly_disposable_income: applicant_disposable_income_subtotals.total_monthly_disposable_income + partner_disposable_income_subtotals.total_monthly_disposable_income,
      )
    end

    def disposable_income_subtotals_without_partner(gross_income_subtotals)
      applicant = PersonWrapper.new person: assessment.applicant, is_single: true,
                                    dependants: assessment.dependants, gross_income_summary: assessment.gross_income_summary
      eligible_for_childcare = calculate_childcare_eligibility(applicant)
      applicant_disposable_income_subtotals = collate_outgoings(applicant,
                                                                assessment.disposable_income_summary,
                                                                gross_income_subtotals.applicant_gross_income_subtotals,
                                                                eligible_for_childcare:,
                                                                allow_negative_net: false,
                                                                partner_allowance: 0)

      DisposableIncomeData.new(
        applicant_disposable_income_subtotals:,
        partner_disposable_income_subtotals: PersonDisposableIncomeSubtotals.new,
        combined_monthly_outgoings: applicant_disposable_income_subtotals.total_monthly_outgoings,
        combined_monthly_disposable_income: applicant_disposable_income_subtotals.total_monthly_disposable_income,
      )
    end

    def collate_and_assess_capital(combined_monthly_disposable_income)
      CapitalCollatorAndAssessor.call assessment, total_monthly_disposable_income: combined_monthly_disposable_income
    end

    def calculate_childcare_eligibility(applicant, partner = nil)
      Calculators::ChildcareEligibilityCalculator.call(
        applicant:,
        partner:,
        dependants: Dependant.where(assessment:), # Ensure we consider both client and partner dependants
        submission_date: assessment.submission_date,
      )
    end

    def partner_allowance
      Threshold.value_for(:partner_allowance, at: assessment.submission_date)
    end

    def collate_outgoings(person, disposable_income_summary, gross_income_subtotals, eligible_for_childcare:, allow_negative_net:, partner_allowance:)
      Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                        person:,
                                        disposable_income_summary:,
                                        gross_income_subtotals:,
                                        eligible_for_childcare:,
                                        allow_negative_net:,
                                        partner_allowance:)
    end
  end
end
