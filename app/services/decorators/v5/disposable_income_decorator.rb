module Decorators
  module V5
    class DisposableIncomeDecorator
      attr_reader :record, :categories

      def initialize(summary, person_subtotals)
        @summary = summary
        @person_subtotals = person_subtotals
        @categories = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
      end

      def as_json
        {
          monthly_equivalents:,
          childcare_allowance:,
          deductions:,
        }
      end

    private

      def monthly_equivalents
        {
          all_sources: transactions(:all_sources),
          bank_transactions: transactions(:bank),
          cash_transactions: transactions(:cash),
        }
      end

      def transactions(source)
        {
          child_care: @person_subtotals.categorised_outgoings(source, :child_care).to_f,
          rent_or_mortgage: @person_subtotals.categorised_outgoings(source, :rent_or_mortgage).to_f,
          maintenance_out: @person_subtotals.categorised_outgoings(source, :maintenance_out).to_f,
          legal_aid: @person_subtotals.categorised_outgoings(source, :legal_aid).to_f,
        }
      end

      def childcare_allowance
        @person_subtotals.categorised_outgoings(:all_sources, :child_care).to_f
      end

      def deductions
        {
          dependants_allowance: @person_subtotals.dependant_allowance.to_f,
          disregarded_state_benefits: Calculators::DisregardedStateBenefitsCalculator.call(@summary).to_f,
        }
      end
    end
  end
end
