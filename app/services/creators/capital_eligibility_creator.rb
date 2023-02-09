module Creators
  class CapitalEligibilityCreator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
      @summary = assessment.capital_summary
    end

    def call
      @assessment.proceeding_types.map(&:ccms_code).each { |ptc| create_eligibility(ptc) }
    end

  private

    def create_eligibility(ptc)
      return if eligibility_record_exists?(ptc)

      if @assessment.level_of_representation == "controlled"
        @summary.eligibilities.create!(
          proceeding_type_code: ptc,
          upper_threshold: controlled_threshold(ptc),
          lower_threshold: controlled_threshold(ptc),
          assessment_result: "pending",
        )
      else
        @summary.eligibilities.create!(
          proceeding_type_code: ptc,
          upper_threshold: upper_threshold(ptc),
          lower_threshold:,
          assessment_result: "pending",
        )
      end
    end

    def controlled_threshold(ptc)
      if ptc.to_sym.in? CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES
        Threshold.value_for(:capital_first_tier_tribunal_controlled, at: @assessment.submission_date)
      else
        @assessment.proceeding_types.find_by!(ccms_code: ptc).capital_upper_threshold
      end
    end

    def lower_threshold
      Threshold.value_for(:capital_lower_certificated, at: @assessment.submission_date)
    end

    def upper_threshold(ptc)
      @assessment.proceeding_types.find_by!(ccms_code: ptc).capital_upper_threshold
    end

    def eligibility_record_exists?(ptc)
      @summary.eligibilities.where(proceeding_type_code: ptc).any?
    end
  end
end
