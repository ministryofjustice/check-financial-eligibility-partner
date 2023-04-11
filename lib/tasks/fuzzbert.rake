require 'rake'
require 'fuzzbert/rake_task'

desc "Run FuzzBert random test suite"
task fuzz: :environment do
  FuzzBert::RakeTask.new(:fuzz) do |spec|
    spec.fuzzbert_opts = ['--limit 10000000', '--console']
    spec.pattern = 'fuzz/**/fuzz_*.rb'
  end
end
