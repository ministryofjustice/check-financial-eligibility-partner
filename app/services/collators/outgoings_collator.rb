module Collators
  class OutgoingsCollator
    class << self
      def call(submission_date:, person:, disposable_income_summary:, eligible_for_childcare:, allow_negative_net:, partner_allowance:, gross_income_subtotals:)
        childcare_subtotals = Collators::ChildcareCollator.call(gross_income_summary: person.gross_income_summary,
                                                                disposable_income_summary:,
                                                                eligible_for_childcare:)

        legal_aid_subtotals = Collators::LegalAidCollator.call(disposable_income_summary, person.gross_income_summary)

        maintenance_subtotals = Collators::MaintenanceCollator.call(disposable_income_summary, person.gross_income_summary)

        dependant_allowance = Collators::DependantsAllowanceCollator.call(dependants: person.dependants,
                                                                          submission_date:)

        housing_costs_subtotals = Collators::HousingCostsCollator.call(disposable_income_summary:,
                                                                       person:,
                                                                       submission_date:,
                                                                       allow_negative_net:)

        category_subtotals = [childcare_subtotals, maintenance_subtotals, legal_aid_subtotals]

        total_monthly_outgoings = sum_total_monthly_outgoings(category_subtotals.sum(&:all_sources),
                                                              housing_costs_subtotals.net_housing_costs,
                                                              gross_income_subtotals.employment_income_subtotals,
                                                              dependant_allowance,
                                                              partner_allowance)
        PersonDisposableIncomeSubtotals.new(
          category_subtotals:,
          dependant_allowance:,
          housing_costs_subtotals:,
          partner_allowance:,
          total_monthly_outgoings:,
          total_monthly_disposable_income: gross_income_subtotals.total_gross_income - total_monthly_outgoings,
        )
      end

      def sum_total_monthly_outgoings(non_housing_outgoings, net_housing_costs, employment_income_subtotals, dependant_allowance, partner_allowance)
        non_housing_outgoings +
          net_housing_costs +
          dependant_allowance +
          partner_allowance -
          employment_income_subtotals.fixed_employment_allowance -
          employment_income_subtotals.employment_income_deductions
      end
    end
  end
end
