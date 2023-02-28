module Calculators
  class MonthlyIncomeConverter
    class << self
      def call(frequency, payments)
        raise "Unrecognized frequency" unless frequency.in?(CFEConstants::VALID_FREQUENCIES)

        send("process_#{frequency}", payments)
      end

    private

      def process_monthly(payments)
        payment_average(payments).round(2)
      end

      def process_four_weekly(payments)
        ((payment_average(payments) / 4) * 52 / 12).round(2)
      end

      def process_two_weekly(payments)
        ((payment_average(payments) / 2) * 52 / 12).round(2)
      end

      def process_weekly(payments)
        (payment_average(payments) * 52 / 12).round(2)
      end

      def process_unknown(payments)
        (payments.sum.to_d / CFEConstants::NUMBER_OF_MONTHS_TO_AVERAGE).round(2)
      end

      def payment_average(payments)
        payments.sum.to_d / payments.size
      end
    end
  end
end
