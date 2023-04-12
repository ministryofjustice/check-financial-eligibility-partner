require "rake"
require "fuzzbert/rake_task"

class FuzzBert::RakeTask < ::Rake::TaskLib
  def initialize(*args)
    super()
    # configure the rake task
    setup_ivars(args)
    yield self if block_given?

    desc "Run FuzzBert random test suite"

    task name => :environment do
      run_task
    end
  end

  def run_task
    system(command)
  end
end

desc "Run FuzzBert random test suite"
task fuzz: :environment do
  FuzzBert::RakeTask.new(:fuzz) do |spec|
    spec.fuzzbert_opts = ["--limit 10000000", "--console"]
    spec.pattern = "fuzz/**/fuzz_*.rb"
  end
end
