require "rails_helper"

describe PartnerFinancialsController, :calls_bank_holiday, type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }
  let(:assessment) do
    create :assessment,
           :with_applicant,
           :with_capital_summary,
           :with_gross_income_summary,
           :with_disposable_income_summary
  end
  let(:date_of_birth) { Faker::Date.backward.to_s }

  describe "POST /assessments/:assessment_id/partner_financials" do
    before do
      post assessment_partner_financials_path(assessment), params: partner_financials_params.to_json, headers:
    end

    context "with outgoings" do
      let(:partner_financials_params) do
        {
          "partner": {
            "date_of_birth": "1980-11-20",
            "employed": true,
          },
          "dependants": [
            {
              "date_of_birth": "2022-11-20",
              "in_full_time_education": false,
              "relationship": "child_relative",
              "monthly_income": 0,
              "assets_value": 0,
            },
          ],
          "employments": [
            {
              "name": "job-1-dec",
              "client_id": "job1-id-uuid",
              "payments": [
                {
                  "client_id": "job1-december-pay-uuid",
                  "date": "2020-12-1",
                  "gross": 450.00,
                  "benefits_in_kind": 0,
                  "tax": -10.04,
                  "national_insurance": -5.02,
                },
                {
                  "client_id": "job-1-november-pay-uuid",
                  "date": "2020-11-01",
                  "gross": 450.00,
                  "benefits_in_kind": 0,
                  "tax": -10.04,
                  "national_insurance": -5.02,
                },
                {
                  "client_id": "job-1-october-pay-uuid",
                  "date": "2020-10-01",
                  "gross": 450,
                  "benefits_in_kind": 0,
                  "tax": -10.04,
                  "national_insurance": -5.02,
                },
              ],
            },
          ],
          "outgoings": [
            {
              "name": "rent_or_mortgage",
              "payments": [
                {
                  "payment_date": "2021-05-10",
                  "amount": 600,
                  "housing_cost_type": "rent",
                  "client_id": "id7",
                },
                {
                  "payment_date": "2021-04-10",
                  "amount": 600,
                  "housing_cost_type": "rent",
                  "client_id": "id8",
                },
                {
                  "payment_date": "2021-03-10",
                  "amount": 600,
                  "housing_cost_type": "rent",
                  "client_id": "id9",
                },
              ],
            },
          ],
          "capitals": {
            "bank_accounts": [
              {
                "value": 420,
                "description": "Bank acct 1",
              },
              {
                "value": 200,
                "description": "Bank acct 2",
              },
            ],
          },
        }
      end
      let(:employments) do
        {
          "employment_income": [
            {
              "name": "job-1-dec",
              "client_id": "job1-id-uuid",
              "payments": [
                {
                  "client_id": "job1-december-pay-uuid",
                  "date": "2020-12-18",
                  "gross": 2526.00,
                  "benefits_in_kind": 0,
                  "tax": -244.60,
                  "national_insurance": -208.08,
                },
                {
                  "client_id": "job-1-november-pay-uuid",
                  "date": "2020-11-28",
                  "gross": 2526.00,
                  "benefits_in_kind": 0,
                  "tax": -244.6,
                  "national_insurance": -208.08,
                },
                {
                  "client_id": "job-1-october-pay-uuid",
                  "date": "2020-10-28",
                  "gross": 2526.00,
                  "benefits_in_kind": 0,
                  "tax": -244.6,
                  "national_insurance": -208.08,
                },
              ],
            },
          ],
        }
      end
      let(:proceeding_types) do
        [
          {
            "ccms_code": "DA001",
            "client_involvement_type": "A",
          },
          {
            "ccms_code": "SE013",
            "client_involvement_type": "A",
          },
          {
            "ccms_code": "SE003",
            "client_involvement_type": "A",
          },
        ]
      end

      it "produces a success response" do
        expect(parsed_response).to eq(success: true, errors: [])
      end

      it "produces partner capital" do
        post("/assessments/#{assessment.id}/employments", params: employments.to_json, headers:)
        post("/assessments/#{assessment.id}/proceeding_types", params: proceeding_types.to_json, headers:)

        expect(get("/assessments/#{assessment.id}")).to eq(200)
        summary = JSON.parse(response.body, symbolize_names: true).fetch(:result_summary)
        expect(summary.fetch(:overall_result).except(:proceeding_types))
          .to eq({
            result: "contribution_required",
            capital_contribution: 0.0,
            income_contribution: 1034.1,
          })
        expect(summary.fetch(:partner_capital))
          .to eq({
            pensioner_disregard_applied: 0.0,
            total_liquid: 620.0,
            total_non_liquid: 0.0,
            total_vehicle: 0.0,
            total_property: 0.0,
            total_mortgage_allowance: 999_999_999_999.0,
            total_capital: 620.0,
            subject_matter_of_dispute_disregard: 0.0,
            capital_contribution: 0,
            assessed_capital: 620.0,
            total_capital_with_smod: 620.0,
            disputed_non_property_disregard: 0.0,
          })
      end
    end
  end
end
