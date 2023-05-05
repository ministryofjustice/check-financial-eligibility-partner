# This test is a replica of test case 1 in OPA Spreadsheet WP3/WP3_E2E_Sc1 (line 1)
#  It interfaces with the following spreadsheet fields:
#  inputs:
#  the value of the mortgage repayment per calendar month
#  the frequency of payment for the client's working tax credit (4-Weekly)
#  the client receives working tax credit
#  the amount the client receives for working tax credit
#  the client is receiving a passported benefit
#  the housing costs deduction (?)
#  the client is employed
#  the client's date of birth
#  outputs:
#  the client overall eligibility (In Scope)
#  total client gross income
#  the total value of all income deductions
#  the value of disposable income
#  the gross value of housing costs
#  the total net value of housing costs
#  the total value of the client's deductions
Feature:
  "OPA WP3 E2E Sc1"

  Scenario: Test Case 1
    Given I am undertaking a certificated assessment
    And I am using version 5 of the API
    And I create an assessment with the following details:
      | submission_date     | 2022-06-10 |
    And I add the following applicant details for the current assessment:
      | date_of_birth               | 1980-07-07 |
      | involvement_type            | applicant  |
      | has_partner_opponent        | false      |
      | receives_qualifying_benefit | false      |
    And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
      | payment_date | housing_cost_type | client_id | amount |
      | 2022-05-10   | mortgage          | id7       | 900    |
      | 2022-04-10   | mortgage          | id8       | 900    |
      | 2022-03-10   | mortgage          | id9       | 900    |
    # This should have been 'benefits' but currently CFE ignores 'other_income/benefits' (LEP-102)
    And I add the following other_income details for "maintenance_in" in the current assessment:
      | date       | client_id            | amount |
      | 2022-05-10 | working-tax-credit-1 | 87.97  |
      | 2022-04-12 | working-tax-credit-2 | 87.97  |
      | 2022-03-15 | working-tax-credit-3 | 87.97  |
    And I add the following employment details:
      | client_id |     date     |  gross | benefits_in_kind  | tax     | national_insurance  |
      |     C     |  2022-05-10  | 1000.0 |       0           | -200.00 |       -80.0         |
      |     C     |  2022-04-12  | 1000.0 |       0           | -200.00 |       -80.0         |
      |     C     |  2022-03-15  | 1000.0 |       0           | -200.00 |       -80.0         |
    When I retrieve the final assessment
    Then I should see the following "gross_income_summary" details:
      | attribute                      | value    |
      | total_gross_income             | 1178.63  |
    Then I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | total_outgoings_and_allowances |  893.34  |
      | gross_housing_costs            |  900.0   |
      | net_housing_costs              |  545.0   |
      | total_disposable_income        |  285.29  |
    And I should see the following overall summary:
      | attribute                      | value    |
      | assessment_result              | eligible |
      | income contribution            |      0.0 |
