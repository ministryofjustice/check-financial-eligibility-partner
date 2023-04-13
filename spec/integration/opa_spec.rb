require "rails_helper"

Dir[Rails.root.join("lib/integration_helpers/opa/**/*.rb")].sort.each { |f| require f }

RSpec.describe "OPA Spreadsheet Runner", :calls_bank_holiday do
  let(:request_headers) { { "CONTENT_TYPE" => "application/json" } }

  Dir.glob(Rails.root.join("spec/integration/opa/**/*.xlsx")).each do |excel_file|
    let(:spreadsheet) { Roo::Spreadsheet.open(excel_file) }
    let(:json) { JSON.parse(response.body, symbolize_names: true) }

    it "can call the API" do
      inputs = Opa::Spreadsheet::Inputs.new(spreadsheet)
      outputs = Opa::Spreadsheet::Output.new(spreadsheet)
      inputs.each do |input|
        post "/v6/assessments", params: input.except(:test_case).to_json, headers: request_headers
        expect(json[:errors]).to be_nil
        expect(response).to have_http_status(:ok)
        output = json.fetch(:result_summary).transform_values { |v| v.except(:proceeding_types, :employment_income) }
        expect(output).to eq(outputs.expected(input.fetch(:test_case)))
      end
    end

    it "can parse the spreadsheet" do
      inputs = Opa::Spreadsheet::Inputs.new(spreadsheet)
      expect(inputs.first)
        .to eq({
          test_case: 1,
          assessment: {
            submission_date: "2022-06-10",
          },
          applicant: {
            date_of_birth: "1980-07-07",
            has_partner_opponent: false,
            receives_qualifying_benefit: false,
          },
          proceeding_types: [{ ccms_code: "SE003", client_involvement_type: "A" }],
          outgoings: [
            name: "rent_or_mortgage",
            payments: [
              { payment_date: "2022-05-10", housing_cost_type: "mortgage", client_id: "1", amount: 900 },
              { payment_date: "2022-04-10", housing_cost_type: "mortgage", client_id: "2", amount: 900 },
              { payment_date: "2022-03-10", housing_cost_type: "mortgage", client_id: "3", amount: 900 },
            ],
          ],
          other_incomes: [
            { source: "maintenance_in",
              payments: [
                { date: "2022-05-10", client_id: "0", amount: 87.97 },
                { date: "2022-04-12", client_id: "1", amount: 87.97 },
                { date: "2022-03-15", client_id: "2", amount: 87.97 },
              ] },
          ],
          employment_income: [
            {
              name: "A",
              client_id: "B",
              payments: [
                { date: "2022-05-10", client_id: "0", benefits_in_kind: 0, gross: 1000, tax: -200, national_insurance: -80 },
                { date: "2022-04-12", client_id: "1", benefits_in_kind: 0, gross: 1000, tax: -200, national_insurance: -80 },
                { date: "2022-03-15", client_id: "2", benefits_in_kind: 0, gross: 1000, tax: -200, national_insurance: -80 },
              ],
            },
          ],
        })
    end
  end
end
