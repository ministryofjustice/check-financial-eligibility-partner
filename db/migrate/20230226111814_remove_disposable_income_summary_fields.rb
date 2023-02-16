class RemoveDisposableIncomeSummaryFields < ActiveRecord::Migration[7.0]
  def change
    change_table :disposable_income_summaries, bulk: true do |t|
      t.remove :combined_total_disposable_income,
               :combined_total_outgoings_and_allowances,
               type: :decimal

      t.remove :net_housing_costs,
               :housing_benefit,
               :income_contribution,
               :child_care_all_sources,
               :maintenance_out_all_sources,
               :rent_or_mortgage_all_sources,
               :legal_aid_all_sources,
               :child_care_bank,
               :maintenance_out_bank,
               :rent_or_mortgage_bank,
               :legal_aid_bank,
               :child_care_cash,
               :maintenance_out_cash,
               :rent_or_mortgage_cash,
               :legal_aid_cash,
               type: :decimal, default: 0

      t.remove :dependant_allowance,
               :gross_housing_costs,
               :total_outgoings_and_allowances,
               :total_disposable_income,
               :lower_threshold,
               :upper_threshold,
               :employment_income_deductions,
               :fixed_employment_allowance,
               :tax,
               :national_insurance,
               type: :decimal, default: 0, null: false

      t.remove :assessment_result, type: :string, default: "pending", null: false
    end
  end
end
