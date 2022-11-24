module ChildcareEligibility
private

  # A person may count their childcare costs towards their assessed outgoings
  # if either the applicant or their partner has a child dependant and if
  # the person who has the childcare costs is either employed or a student
  def eligible_for_childcare_costs?(person, submission_date, all_dependants)
    assessment_has_dependant_child?(all_dependants, submission_date) &&
      (person.employed? || person.has_student_loan?)
  end

  def assessment_has_dependant_child?(dependants, submission_date)
    dependants.any? do |dependant|
      submission_date.before?(dependant.becomes_adult_on)
    end
  end
end
