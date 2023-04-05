module Creators
  class FullAssessmentCreator
    class << self
      CreationResult = Struct.new :errors, :assessment, keyword_init: true do
        def success?
          errors.empty?
        end
      end

      def call(remote_ip:, params:)
          create = Creators::AssessmentCreator.call(remote_ip:,
                                                    assessment_params: params[:assessment],
                                                    version: CFEConstants::FULL_ASSESSMENT_VERSION)
          assessment = create.assessment

        errors = CREATE_FUNCTIONS.map { |f|
          f.call(assessment, params)
        }.compact.reject(&:success?).map(&:errors).reduce([], :+)

        CreationResult.new(errors:, assessment: create.assessment.reload).freeze
      end

      CREATE_FUNCTIONS = [
        lambda { |assessment, params|
          validator = JsonSwaggerValidator.new "proceeding_types", { proceeding_types: params[:proceeding_types] }
          if validator.valid?
            Creators::ProceedingTypesCreator.call(assessment_id: assessment.id,
                                                  proceeding_types_params: { proceeding_types: params[:proceeding_types] })
          else
            CreationResult.new(errors: validator.errors).freeze
          end
        },
        lambda { |assessment, params|
          validator = JsonSwaggerValidator.new "applicant", { applicant: params[:applicant] }
          if validator.valid?
            Creators::ApplicantCreator.call(assessment:,
                                            applicant_params: { applicant: params[:applicant] })
          else
            CreationResult.new(errors: validator.errors).freeze
          end
        },
        lambda { |assessment, params|
          if params[:dependants]
            validator = JsonSwaggerValidator.new "dependants", { dependants: params[:dependants] }
            if validator.valid?
              Creators::DependantsCreator.call(assessment_id: assessment.id,
                                               dependants_params: { dependants: params[:dependants] })
            else
              CreationResult.new(errors: validator.errors).freeze
            end
          end
        },
        lambda { |assessment, params|
          if params[:cash_transactions]
            validator = JsonSwaggerValidator.new "cash_transactions", params[:cash_transactions]
            if validator.valid?
              Creators::CashTransactionsCreator.call(assessment_id: assessment.id,
                                                     cash_transaction_params: params[:cash_transactions])
            else
              CreationResult.new(errors: validator.errors).freeze
            end
          end
        },
        lambda { |assessment, params|
          if params[:employment_income]
            Creators::EmploymentsCreator.call(employment_collection: assessment.employments,
                                              employments_params: { employment_income: params[:employment_income] })
          end
        },
        lambda { |assessment, params|
          if params[:irregular_incomes]
            Creators::IrregularIncomeCreator.call(irregular_income_params: params[:irregular_incomes],
                                                  gross_income_summary: assessment.gross_income_summary)
          end
        },
        lambda { |assessment, params|
          if params[:other_incomes]
            Creators::OtherIncomesCreator.call(assessment:,
                                               other_incomes_params: { other_incomes: params[:other_incomes] })
          end
        },
        lambda { |assessment, params|
          if params[:state_benefits]
            Creators::StateBenefitsCreator.call(assessment_id: assessment.id,
                                                state_benefits_params: { state_benefits: params[:state_benefits] })
          end
        },
        lambda { |assessment, params|
          if params[:vehicles]
            Creators::VehicleCreator.call(capital_summary: assessment.capital_summary,
                                          vehicles_params: { vehicles: params[:vehicles] })
          end
        },
        lambda { |assessment, params|
          if params[:capitals]
            Creators::CapitalsCreator.call(capital_params: params[:capitals],
                                           capital_summary: assessment.capital_summary)
            # CapitalsCreator no longer returns errors - it throws exceptions
            CreationResult.new(errors: [])
          end
        },
        lambda { |assessment, params|
          if params[:regular_transactions]
            Creators::RegularTransactionsCreator.call(
              assessment_id: assessment.id,
              regular_transaction_params: { regular_transactions: params[:regular_transactions] },
            )
          end
        },
        lambda { |assessment, params|
          if params[:outgoings]
            Creators::OutgoingsCreator.call(disposable_income_summary: assessment.disposable_income_summary,
                                            outgoings_params: { outgoings: params[:outgoings] })
          end
        },
        lambda { |assessment, params|
          if params[:properties]
            Creators::PropertiesCreator.call(assessment_id: assessment.id,
                                             properties_params: { properties: params[:properties] })
          end
        },
        lambda { |assessment, params|
          if params[:partner]
            Creators::PartnerFinancialsCreator.call(assessment_id: assessment.id,
                                                    partner_financials_params: params[:partner])
          end
        },
        lambda { |assessment, params|
          if params[:explicit_remarks]
            Creators::ExplicitRemarksCreator.call(assessment_id: assessment.id,
                                                  explicit_remarks_params: { explicit_remarks: params[:explicit_remarks] })
          end
        },
      ].freeze
    end
  end
end
