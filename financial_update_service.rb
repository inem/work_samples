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


class StockService
  def self.financial_update(stock)
    updated_on = last_updated_on(stock)
    latest_financial_data = fetch_latest_financial_data(stock, updated_on)
    financial_data = remove_duplicate_data(latest_financial_data, updated_on)
    store_latest_financial_data(stock, financial_data)
  end
  
  def self.last_updated_on(stock)
    stock.financials.first.date.to_date
  end

  def self.fetch_latest_financial_data(stock, updated_on)
    @stock_api.new(stock.symbol, {start_date: updated_on, end_date: Date.today-1}).financial_history
  end

  def self.remove_duplicate_data(financial_data, updated_on)
    financial_data.delete_if { |data| data[:date].to_date <= updated_on}
  end

  def self.store_latest_financial_data(stock, financial_data)
    financial_data.each do |d| 
      stock.financials.create(adj_close: d.fetch(:adj_close), close: d.fetch(:close),
      date: d.fetch(:date).to_time, high: d.fetch(:high), low: d.fetch(:low), open: d.fetch(:open),
      volume: d.fetch(:volume))
    end
  end
end
