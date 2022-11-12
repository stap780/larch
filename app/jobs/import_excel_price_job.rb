class ImportExcelPriceJob < ApplicationJob
  queue_as :default

  def perform(excel_price)
    # Do something later
    Services::Import.excel_price(excel_price)
  end
end
