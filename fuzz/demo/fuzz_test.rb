require "fuzzbert"
require "faraday"
require "json"

module FuzzBert::Handler
  class FileOutput
    def handle(error_data)
      id = error_data[:id]
      data = error_data[:data]
      status = error_data[:status]
      pid = error_data[:pid]

      crashed = status.termsig
      prefix = crashed ? "crash" : "bug"

      filename = "#{dir_prefix}#{prefix}#{pid}"
      filename << ("a".."z").to_a.sample while File.exist?(filename)
      File.open(filename, "wb") { |f| f.print(data) }

      puts "#{id} failed. Data was saved as #{filename}."
      info(error_data)
    end
  end
end

fuzz "Web App" do
  params = {
    assessment: { submission_date: "2023-04-04" },
    applicant: { date_of_birth: "2001-02-02",
                 has_partner_opponent: false,
                 receives_qualifying_benefit: false,
                 employed: false },
    proceeding_types: [{ ccms_code: "DA001", client_involvement_type: "A" }],
  }
  # f = Faraday.new "http://localhost:3000/v6/assessments" do |faraday|
  #   faraday.request :json
  #   faraday.response :json, parser_options: { symbolize_names: true }
  # end
  http = Net::HTTP.new "http://localhost:3000/"

  deploy do |data|
    puts "sending #{data}"
    # send JSON data via HTTP
    # f.post do |x|
    #   x.body = params
    # end
    req = Net::HTTP::Post.new "/v6/assessments"
    req.body = params.to_json
    req.content_type = "application/json"
    http.request req
  end

  data "template" do
    t = FuzzBert::Template.new <<-TEMPLATE
      { user: { id: ${id}, name: "${name}", text: "${text}" } }
    TEMPLATE
    t.set(:id, FuzzBert::Generators.cycle(1..10_000))
    name = FuzzBert::Container.new
    name << FuzzBert::Generators.fixed("fixed")
    # name << FuzzBert::Generators.random_fixlen(2)
    t.set(:name, name.generator)
    t.set(:text) { "Fixed text" }
    t.generator
  end
end
