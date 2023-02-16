# used to convert DB layer into domain layer for rules
class PersonWrapper
  delegate :employed?, to: :@person
  delegate :housing_benefit_payments, to: :@gross_income_summary

  attr_reader :dependants, :gross_income_summary

  def initialize(person:, is_single:, dependants:, gross_income_summary:)
    @person = person
    @is_single = is_single
    @dependants = dependants
    @gross_income_summary = gross_income_summary
  end

  def is_student?
    @gross_income_summary.student_loan_payments.any?
  end

  def single?
    @is_single
  end
end
