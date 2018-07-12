# This class was written for an application with Financial Data
# that needs to be updated weekly.

# This is a properly constructed service object following
# the single responsibility principle

# The class contains a single method to run the service named "run"
# which contains descriptive method names of the actions that will
# be performed.

# Highlights: This class stores the date of the most recent financial
# data into @last_updated_on which keeps from issuing queries to the DB
# everytime we need to know when the stock was last updated.

class StockMutator
  def self.create_financials!(stock, financial_data)
    financial_data.each do |d| 
      stock.financials.create(adj_close: d.fetch(:adj_close), close: d.fetch(:close),
      date: d.fetch(:date).to_time, high: d.fetch(:high), low: d.fetch(:low), open: d.fetch(:open),
      volume: d.fetch(:volume))
    end
  end
end


class StockService
  def self.financial_update!(stock)
    last_updated_on = stock.financials.first.date.to_date
    latest_financial_data = StockDataApi.new(stock.symbol, {start_date: last_updated_on, end_date: Date.today-1}).financial_history
    fresh_financial_data = latest_financial_data.delete_if { |data| data[:date].to_date <= last_updated_on}
    StockMutator.create_financials!(stock, fresh_financial_data)
  end
end
