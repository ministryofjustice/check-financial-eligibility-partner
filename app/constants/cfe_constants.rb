module CFEConstants
  # Versions
  #
  DEFAULT_ASSESSMENT_VERSION = "5".freeze
  FULL_ASSESSMENT_VERSION = "6".freeze
  VALID_ASSESSMENT_VERSIONS = %w[5 6].freeze

  # Valid CCMS Codes for proceeding types - probably need to get this from LFA in future
  #
  DOMESTIC_ABUSE_CCMS_CODES = %i[DA001 DA002 DA003 DA004 DA005 DA006 DA007 DA020].freeze
  CHILD_SECTION_8_CCMS_CODES = %i[SE003 SE004 SE013 SE014].freeze
  FULL_SECTION_8_CCMS_CODES = %i[SE007 SE008 SE015 SE016 SE095 SE097].freeze
  SECTION_8_APPEAL_CCMS_CODES = %i[SE003A SE004A SE007A SE008A SE013A SE014A SE015A SE016A SE095A SE097A SE101A].freeze
  SECTION_8_ENFORCEMENT_CCMS_CODES = %i[SE003E SE004E SE007E SE008E SE013E SE014E SE015E SE016E SE096E SE099E SE100E SE101E].freeze
  IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE = :IM030
  ASYLUM_PROCEEDING_TYPE_CCMS_CODE = :IA031
  IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES = [IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE, ASYLUM_PROCEEDING_TYPE_CCMS_CODE].freeze
  VALID_PROCEEDING_TYPE_CCMS_CODES = (DOMESTIC_ABUSE_CCMS_CODES +
    CHILD_SECTION_8_CCMS_CODES +
    FULL_SECTION_8_CCMS_CODES +
    SECTION_8_APPEAL_CCMS_CODES +
    IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES +
    SECTION_8_ENFORCEMENT_CCMS_CODES).freeze

  # Income categories
  #
  VALID_INCOME_CATEGORIES = %w[benefits friends_or_family maintenance_in property_or_lodger pension].freeze
  VALID_REGULAR_INCOME_CATEGORIES = VALID_INCOME_CATEGORIES + %w[housing_benefit].freeze
  HUMANIZED_INCOME_CATEGORIES = (VALID_INCOME_CATEGORIES + VALID_INCOME_CATEGORIES.map(&:humanize)).freeze

  # Outgoings categories
  #
  OUTGOING_KLASSES = {
    child_care: Outgoings::Childcare,
    rent_or_mortgage: Outgoings::HousingCost,
    maintenance_out: Outgoings::Maintenance,
    legal_aid: Outgoings::LegalAid,
  }.freeze
  VALID_OUTGOING_CATEGORIES = OUTGOING_KLASSES.keys.map(&:to_s).freeze
  NON_HOUSING_OUTGOING_CATEGORIES = OUTGOING_KLASSES.except(:rent_or_mortgage).keys.map(&:to_s).freeze
  VALID_OUTGOING_HOUSING_COST_TYPES = %w[rent mortgage board_and_lodging].freeze

  # Remark categories
  #
  VALID_REMARK_CATEGORIES = %w[policy_disregards].freeze
  VALID_REMARK_TYPES = %i[
    other_income_payment
    state_benefit_payment
    outgoings_child_care
    outgoings_childcare
    outgoings_legal_aid
    outgoings_maintenance
    outgoings_maintenance_out
    outgoings_housing_cost
    outgoings_rent_or_mortgage
    current_account_balance
    employment_gross_income
    employment_payment
    employment_tax
    employment_nic
    employment
  ].freeze
  VALID_REMARK_ISSUES = %i[
    unknown_frequency
    amount_variation
    residual_balance
    multi_benefit
    multiple_employments
    refunds
  ].freeze

  # Irregular income categories and frequencies
  #
  ANNUAL_FREQUENCY = "annual".freeze
  QUARTERLY_FREQUENCY = "quarterly".freeze
  MONTHLY_FREQUENCY = "monthly".freeze
  STUDENT_LOAN = "student_loan".freeze
  UNSPECIFIED_SOURCE = "unspecified_source".freeze
  VALID_IRREGULAR_INCOME_FREQUENCIES = [MONTHLY_FREQUENCY, ANNUAL_FREQUENCY, QUARTERLY_FREQUENCY].freeze
  VALID_IRREGULAR_INCOME_TYPES = [STUDENT_LOAN, UNSPECIFIED_SOURCE].freeze

  # Date and bank holidays
  #
  DATE_REGEX = /^([12][9|0][0-9]{2}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]))$/
  GOVUK_BANK_HOLIDAY_API_URL = "https://www.gov.uk/bank-holidays.json".freeze
  GOVUK_BANK_HOLIDAY_DEFAULT_GROUP = "england-and-wales".freeze

  # Frequencies
  #
  VALID_REGULAR_TRANSACTION_FREQUENCIES = %i[three_monthly monthly four_weekly two_weekly weekly unknown].freeze
  VALID_FREQUENCIES = %i[monthly four_weekly two_weekly weekly unknown].freeze
  NUMBER_OF_MONTHS_TO_AVERAGE = 3

  # client_involvement_types
  #
  VALID_CLIENT_INVOLVEMENT_TYPES = %w[A D W Z I].freeze

  # Number of days before assessment is considered stale and eligible for deletion
  #
  STALE_ASSESSMENT_THRESHOLD_DAYS = 14
end
