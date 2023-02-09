class PersonGrossIncomeSubtotals
  def initialize(gross_income_components = {})
    @total_gross_income = gross_income_components[:total_gross_income]
    @monthly_student_loan = gross_income_components[:monthly_student_loan]
    @monthly_unspecified_source = gross_income_components[:monthly_unspecified_source]
    @regular_income_categories = gross_income_components[:regular_income_categories]
    @employment_income_subtotals = gross_income_components[:employment_income_subtotals] || instantiate_blank_income_subtotals
  end

  def monthly_regular_incomes(income_type, income_category)
    return 0 unless @regular_income_categories

    category_data = @regular_income_categories.find { _1.category == income_category }
    category_data.send(income_type)
  end

  attr_reader :total_gross_income,
              :monthly_student_loan,
              :monthly_unspecified_source,
              :employment_income_subtotals

private

  def instantiate_blank_income_subtotals
    EmploymentIncomeSubtotals.new
  end
end
