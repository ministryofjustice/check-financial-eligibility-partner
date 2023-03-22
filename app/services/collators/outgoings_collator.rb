module Collators
  class OutgoingsCollator
    class << self
      def call(submission_date:, person:, gross_income_summary:, disposable_income_summary:, eligible_for_childcare:, allow_negative_net:)
        # sets child_care_bank and child_care_cash fields in disposable_income_summary
        child_care = Collators::ChildcareCollator.call(gross_income_summary:,
                                                       childcare_outgoings: disposable_income_summary.childcare_outgoings,
                                                       assessment_errors: disposable_income_summary.assessment.assessment_errors,
                                                       eligible_for_childcare:)
        # TODO: Return these values instead of persisting them
        disposable_income_summary.update!(child_care_bank: child_care.bank, child_care_cash: child_care.cash)

        # sets dependant_allowance on each dependant,
        # and dependant_allowance on disposable_income_summary as the sum of them
        dependent_allowance = Collators::DependantsAllowanceCollator.call(dependants: person.dependants,
                                                                          submission_date:)
        disposable_income_summary.update!(dependant_allowance: dependent_allowance)

        # sets maintenance_out_bank on disposable_income_summary
        maintenance_out = Collators::MaintenanceCollator.call(disposable_income_summary:, gross_income_summary:)
        # TODO: return this value instead of persisting it
        disposable_income_summary.update!(maintenance_out_bank: maintenance_out.bank,
                                          maintenance_out_cash: maintenance_out.cash)

        housing_costs = Collators::HousingCostsCollator.call(disposable_income_summary:,
                                                             person:,
                                                             submission_date:,
                                                             allow_negative_net:)
        disposable_income_summary.update! housing_benefit: housing_costs.housing_benefit,
                                          gross_housing_costs: housing_costs.gross_housing_costs.all_sources,
                                          rent_or_mortgage_bank: housing_costs.gross_housing_costs.bank,
                                          rent_or_mortgage_cash: housing_costs.gross_housing_costs.cash,
                                          net_housing_costs: housing_costs.net_housing_costs

        # sets legal_aid_bank on disposable_income_summary
        legal_aid = Collators::LegalAidCollator.call(disposable_income_summary:, gross_income_summary:)
        # TODO: return this instead of persisting it
        disposable_income_summary.update!(legal_aid_bank: legal_aid.bank, legal_aid_cash: legal_aid.cash)
      end
    end
  end
end
