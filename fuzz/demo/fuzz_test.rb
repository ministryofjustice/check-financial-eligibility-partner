require "fuzzbert"

fuzz "Web App" do
  deploy do |data|
    puts "sending #{data}"
    # send JSON data via HTTP
  end

  data "template" do
    t = FuzzBert::Template.new <<-EOS
      { user: { id: ${id}, name: "${name}", text: "${text}" } }
    EOS
    t.set(:id, FuzzBert::Generators.cycle(1..10_000))
    name = FuzzBert::Container.new
    name << FuzzBert::Generators.fixed("fixed")
    # name << FuzzBert::Generators.random_fixlen(2)
    t.set(:name, name.generator)
    t.set(:text) { "Fixed text" }
    t.generator
  end
end
