module RemarkGenerators
  class BaseChecker
    def self.call(assessment, collection, disposable_income_subtotals = nil)
      new(assessment, collection, disposable_income_subtotals).call
    end

    def initialize(assessment, collection, disposable_income_subtotals)
      @assessment = assessment
      @collection = collection
      @disposable_income_subtotals = disposable_income_subtotals
    end

  private

    attr_reader :disposable_income_subtotals

    def record_type
      @collection.first.class.to_s.underscore.tr("/", "_").to_sym
    end
  end
end
