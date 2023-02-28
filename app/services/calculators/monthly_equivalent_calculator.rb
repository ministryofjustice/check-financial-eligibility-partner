# examines all records in a given collection, to work out the equivalent value per calendar month

module Calculators
  class MonthlyEquivalentCalculator
    class << self
      def call(collection:, date_method: :payment_date, amount_method: :amount)
        return 0.0 if collection.empty?

        dates_and_amounts = Utilities::PaymentPeriodDataExtractor.call(collection:,
                                                                       date_method:,
                                                                       amount_method:)
        dates = dates_and_amounts.map(&:first)
        frequency = Utilities::PaymentPeriodAnalyser.new(dates).period_pattern
        payment_amounts = collection.map(&amount_method)

        Calculators::MonthlyIncomeConverter.call(frequency, payment_amounts)
      end
    end
  end
end
