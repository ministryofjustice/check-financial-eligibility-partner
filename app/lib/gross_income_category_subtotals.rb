class GrossIncomeCategorySubtotals
  def initialize(category:, bank:, cash:, regular:)
    @category = category
    @bank = bank
    @cash = cash
    @regular = regular
  end

  def all_sources
    bank + cash + regular
  end

  attr_reader :category, :bank, :cash, :regular
end
